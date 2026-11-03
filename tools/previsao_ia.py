import mysql.connector
import pandas as pd
import numpy as np
import json
import os
import sys
from datetime import datetime, timedelta
from sklearn.linear_model import LinearRegression
from sklearn.ensemble import IsolationForest

# --- CONFIGURATION ---
import os as _os

def _load_env():
    """Read DB settings from the project's .env (same file PHP uses)."""
    path = _os.path.join(_os.path.dirname(_os.path.dirname(_os.path.abspath(__file__))), '.env')
    if _os.path.exists(path):
        for line in open(path, encoding='utf-8'):
            line = line.strip()
            if line and not line.startswith('#') and '=' in line:
                k, v = line.split('=', 1)
                _os.environ.setdefault(k.strip(), v.strip().strip('"\''))
    return {
        'host': _os.environ.get('DB_HOST', 'localhost'),
        'port': int(_os.environ.get('DB_PORT', 3306)),
        'user': _os.environ.get('DB_USER', 'root'),
        'password': _os.environ.get('DB_PASS', ''),
        'database': _os.environ.get('DB_NAME', 'farmproject'),
    }

DB_CONFIG = _load_env()
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
JSON_FILE = os.path.join(BASE_DIR, 'ai_analysis.json')
ERROR_FILE = os.path.join(BASE_DIR, 'ai_error.log')

# --- HEALTH & ECONOMICS CONSTANTS ---
TARGET_WEIGHT_FINISHING = 650.0  # kg
MARKET_PRICE_AVG = 3.20          # $/kg live weight

def get_db_connection():
    return mysql.connector.connect(**DB_CONFIG)

def analyze_herd():
    conn = get_db_connection()
    
    # 1. Fetch comprehensive dataset
    # Joining Animal, Breed, and most recent weighing data
    query = """
        SELECT 
            a.animal_id, 
            a.tag_number, 
            at.breed,
            a.birth_date,
            w.weight_kg,
            w.weighing_date,
            DATEDIFF(NOW(), a.birth_date) as age_days
        FROM animal a
        JOIN animal_types at ON a.type_id = at.type_id
        JOIN weighing w ON a.animal_id = w.animal_id
        WHERE a.status = 'active'
        ORDER BY a.animal_id, w.weighing_date ASC
    """
    
    df = pd.read_sql(query, conn)
    
    # 2. Fetch Health History (Last 60 days) to correlate
    health_query = """
        SELECT animal_id, COUNT(*) as recent_treatments 
        FROM health_records 
        WHERE treatment_date >= DATE_SUB(NOW(), INTERVAL 60 DAY)
        GROUP BY animal_id
    """
    df_health = pd.read_sql(health_query, conn)
    
    conn.close()

    if df.empty:
        return {"status": "error", "message": "No weighing data found."}

    # --- INTELLIGENCE PROCESSING ---
    
    animals_analysis = []
    
    # Group by animal to calculate individual metrics
    for animal_id, group in df.groupby('animal_id'):
        if len(group) < 2:
            continue # Need at least 2 weights for trends

        # Sort by date
        group = group.sort_values('weighing_date')
        
        # Current status
        current_weight = group.iloc[-1]['weight_kg']
        last_date = group.iloc[-1]['weighing_date']
        breed = group.iloc[0]['breed']
        tag = group.iloc[0]['tag_number']
        
        # Calculate ADG (Average Daily Gain) - Local Slope
        # Using Linear Regression on the last 5 weights for precision
        reg_data = group.tail(5).copy()
        reg_data['days_ordinal'] = pd.to_datetime(reg_data['weighing_date']).map(datetime.toordinal)
        
        model = LinearRegression()
        X = reg_data['days_ordinal'].values.reshape(-1, 1)
        y = reg_data['weight_kg'].values
        model.fit(X, y)
        
        adg_projected = model.coef_[0] # kg per day gain trend
        
        # Predict Days to Target
        days_to_target = 0
        predicted_finish_date = "N/A"
        
        if adg_projected > 0.1:
            remaining_weight = TARGET_WEIGHT_FINISHING - current_weight
            if remaining_weight > 0:
                days_to_target = int(remaining_weight / adg_projected)
                finish_date_obj = datetime.now() + timedelta(days=days_to_target)
                predicted_finish_date = finish_date_obj.strftime('%Y-%m-%d')
            else:
                predicted_finish_date = "Ready"
        
        # Health Risk Analysis (The "Surprise")
        # Logic: If ADG is significantly below breed average or negative, flag it.
        health_risk = "Low"
        health_score = 100
        
        if adg_projected < 0:
            health_risk = "Critical (Weight Loss)"
            health_score = 40
        elif adg_projected < 0.6: # Assuming 0.6kg is a threshold for cattle
            health_risk = "Warning (Stunted Growth)"
            health_score = 70
            
        # Correlate with recent medical history
        recent_sick = df_health[df_health['animal_id'] == animal_id]['recent_treatments'].sum()
        if recent_sick > 0:
            health_score -= (recent_sick * 10)
            
        animals_analysis.append({
            'id': int(animal_id),
            'tag': tag,
            'breed': breed,
            'weight': float(round(current_weight, 2)),
            'adg': float(round(adg_projected, 3)),
            'finish_date': predicted_finish_date,
            'health_score': int(health_score),
            'health_risk': health_risk,
            'revenue_potential': float(round(current_weight * MARKET_PRICE_AVG, 2))
        })

    # --- ANOMALY DETECTION (CROWD ANALYSIS) ---
    # Using Isolation Forest to find animals behaving weirdly compared to the herd
    if len(animals_analysis) > 5:
        analysis_df = pd.DataFrame(animals_analysis)
        X_anomaly = analysis_df[['weight', 'adg', 'health_score']].values
        
        iso_forest = IsolationForest(contamination=0.1, random_state=42)
        analysis_df['anomaly'] = iso_forest.fit_predict(X_anomaly)
        
        # -1 indicates anomaly
        for index, row in analysis_df.iterrows():
            if row['anomaly'] == -1 and row['health_score'] > 60:
                animals_analysis[index]['health_risk'] = "Anomaly Detected (Review)"
                animals_analysis[index]['health_score'] -= 15

    # Structure Output
    final_output = {
        'metadata': {
            'generated_at': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            'total_analyzed': len(animals_analysis)
        },
        'herd_summary': {
            'avg_health_score': round(pd.DataFrame(animals_analysis)['health_score'].mean(), 1),
            'avg_adg': round(pd.DataFrame(animals_analysis)['adg'].mean(), 3),
            'critical_cases': len([x for x in animals_analysis if x['health_score'] < 60])
        },
        'data': sorted(animals_analysis, key=lambda x: x['health_score']) # Show sickest first
    }

    # Save
    with open(JSON_FILE, 'w') as f:
        json.dump(final_output, f, indent=4)
        
    print("Intelligence cycle complete.")

if __name__ == "__main__":
    try:
        analyze_herd()
    except Exception as e:
        with open(ERROR_FILE, 'w') as f:
            f.write(str(e))
        print(f"Error: {str(e)}")