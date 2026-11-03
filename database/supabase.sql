-- =========================================================
-- AgroFarm — PostgreSQL schema + demo data (Supabase)
--
-- How to load it in Supabase:
--   Dashboard > SQL Editor > New query > paste this file > Run
--   (or: psql "<Session pooler connection string>" -f database/supabase.sql)
--
-- Demo login after loading:  demo / AgroFarm2026!  (change it after the first login)
-- =========================================================


-- Name: public; Type: SCHEMA; Schema: -; Owner: -

-- Name: accounts_payable; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.accounts_payable (
    payable_id integer NOT NULL,
    company_id integer NOT NULL,
    supplier_id integer NOT NULL,
    category_id integer NOT NULL,
    description character varying(255) NOT NULL,
    invoice_number character varying(100) DEFAULT NULL::character varying,
    amount numeric(10,2) NOT NULL,
    due_date date NOT NULL,
    payment_date date,
    status character varying DEFAULT 'pending'::character varying,
    file_path character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Name: accounts_payable_payable_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.accounts_payable_payable_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: accounts_payable_payable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.accounts_payable_payable_id_seq OWNED BY public.accounts_payable.payable_id;

-- Name: animal; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.animal (
    animal_id integer NOT NULL,
    tag_number character varying(50) NOT NULL,
    type_id integer NOT NULL,
    birth_date date,
    birth_place character varying(150) DEFAULT NULL::character varying,
    country_id integer NOT NULL,
    sex character varying NOT NULL,
    status character varying DEFAULT 'active'::character varying
);

-- Name: animal_animal_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.animal_animal_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: animal_animal_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.animal_animal_id_seq OWNED BY public.animal.animal_id;

-- Name: animal_types; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.animal_types (
    type_id integer NOT NULL,
    species character varying DEFAULT 'cattle'::character varying NOT NULL,
    breed character varying(100) NOT NULL,
    description text
);

-- Name: animal_types_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.animal_types_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: animal_types_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.animal_types_type_id_seq OWNED BY public.animal_types.type_id;

-- Name: clients; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.clients (
    client_id integer NOT NULL,
    company_id integer NOT NULL,
    name character varying(150) NOT NULL,
    tax_id character varying(50) DEFAULT NULL::character varying,
    email character varying(150) DEFAULT NULL::character varying,
    phone character varying(50) DEFAULT NULL::character varying,
    address character varying(255) DEFAULT NULL::character varying
);

-- Name: clients_client_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.clients_client_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: clients_client_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.clients_client_id_seq OWNED BY public.clients.client_id;

-- Name: company; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.company (
    company_id integer NOT NULL,
    name character varying(150) NOT NULL,
    legal_name character varying(255) DEFAULT NULL::character varying,
    tax_id character varying(50) DEFAULT NULL::character varying,
    owner_name character varying(150) DEFAULT NULL::character varying,
    address character varying(255) DEFAULT NULL::character varying,
    phone character varying(50) DEFAULT NULL::character varying,
    email character varying(150) DEFAULT NULL::character varying,
    logo_path character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Name: company_company_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.company_company_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: company_company_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.company_company_id_seq OWNED BY public.company.company_id;

-- Name: daily_feeding; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.daily_feeding (
    feeding_id integer NOT NULL,
    animal_id integer NOT NULL,
    feed_id integer NOT NULL,
    feeding_date date NOT NULL,
    quantity_kg numeric(10,2) NOT NULL
);

-- Name: daily_feeding_feeding_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.daily_feeding_feeding_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: daily_feeding_feeding_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.daily_feeding_feeding_id_seq OWNED BY public.daily_feeding.feeding_id;

-- Name: european_countries; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.european_countries (
    country_id integer NOT NULL,
    country_name character varying(100) NOT NULL
);

-- Name: european_countries_country_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.european_countries_country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: european_countries_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.european_countries_country_id_seq OWNED BY public.european_countries.country_id;

-- Name: events; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.events (
    event_id integer NOT NULL,
    animal_id integer NOT NULL,
    event_type character varying NOT NULL,
    description text,
    event_date date NOT NULL
);

-- Name: events_event_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.events_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.events_event_id_seq OWNED BY public.events.event_id;

-- Name: feed; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.feed (
    feed_id integer NOT NULL,
    name character varying(150) NOT NULL,
    description text,
    protein_level numeric(5,2) DEFAULT NULL::numeric,
    cost_per_kg numeric(10,2) DEFAULT NULL::numeric,
    supplier_id integer
);

-- Name: feed_feed_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.feed_feed_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: feed_feed_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.feed_feed_id_seq OWNED BY public.feed.feed_id;

-- Name: financial_categories; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.financial_categories (
    category_id integer NOT NULL,
    name character varying(100) NOT NULL,
    type character varying NOT NULL
);

-- Name: financial_categories_category_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.financial_categories_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: financial_categories_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.financial_categories_category_id_seq OWNED BY public.financial_categories.category_id;

-- Name: health_records; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.health_records (
    record_id integer NOT NULL,
    animal_id integer NOT NULL,
    item_id integer,
    treatment_date date NOT NULL,
    vet_name character varying(100) DEFAULT NULL::character varying,
    diagnosis text,
    cost numeric(10,2) DEFAULT 0.00,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Name: health_records_record_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.health_records_record_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: health_records_record_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.health_records_record_id_seq OWNED BY public.health_records.record_id;

-- Name: login_attempts; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.login_attempts (
    id integer NOT NULL,
    ip character varying(45) NOT NULL,
    attempted_at timestamp without time zone NOT NULL
);

-- Name: login_attempts_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.login_attempts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: login_attempts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.login_attempts_id_seq OWNED BY public.login_attempts.id;

-- Name: lot; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.lot (
    lot_id integer NOT NULL,
    company_id integer,
    name character varying(100) NOT NULL,
    creation_date date NOT NULL,
    description text
);

-- Name: lot_animals; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.lot_animals (
    lot_id integer NOT NULL,
    animal_id integer NOT NULL,
    entry_date date NOT NULL,
    exit_date date
);

-- Name: lot_lot_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.lot_lot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: lot_lot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.lot_lot_id_seq OWNED BY public.lot.lot_id;

-- Name: market_prices; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.market_prices (
    price_id integer NOT NULL,
    date date NOT NULL,
    unit_type character varying NOT NULL,
    value numeric(10,2) NOT NULL,
    description character varying(100) DEFAULT NULL::character varying
);

-- Name: market_prices_price_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.market_prices_price_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: market_prices_price_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.market_prices_price_id_seq OWNED BY public.market_prices.price_id;

-- Name: medical_catalog; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.medical_catalog (
    item_id integer NOT NULL,
    item_name character varying(150) NOT NULL,
    type character varying NOT NULL,
    description text,
    cost_price numeric(10,2) DEFAULT 0.00,
    sale_price numeric(10,2) DEFAULT 0.00,
    supplier_id integer,
    stock_quantity integer DEFAULT 0,
    unit character varying(20) DEFAULT 'dose'::character varying,
    withdrawal_days integer DEFAULT 0
);

-- Name: medical_catalog_item_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.medical_catalog_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: medical_catalog_item_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.medical_catalog_item_id_seq OWNED BY public.medical_catalog.item_id;

-- Name: operational_costs; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.operational_costs (
    cost_id integer NOT NULL,
    category character varying NOT NULL,
    cost_value numeric(10,2) NOT NULL,
    cost_date date NOT NULL,
    lot_id integer,
    animal_id integer,
    description text
);

-- Name: operational_costs_cost_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.operational_costs_cost_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: operational_costs_cost_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.operational_costs_cost_id_seq OWNED BY public.operational_costs.cost_id;

-- Name: sales; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.sales (
    sale_id integer NOT NULL,
    company_id integer NOT NULL,
    animal_id integer NOT NULL,
    client_id integer NOT NULL,
    sale_date date NOT NULL,
    final_weight numeric(10,2) NOT NULL,
    price_per_unit numeric(10,2) NOT NULL,
    total_value numeric(10,2) NOT NULL,
    commission numeric(10,2) DEFAULT 0.00,
    net_value numeric(10,2) DEFAULT NULL::numeric
);

-- Name: sales_sale_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.sales_sale_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: sales_sale_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.sales_sale_id_seq OWNED BY public.sales.sale_id;

-- Name: suppliers; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.suppliers (
    supplier_id integer NOT NULL,
    name character varying(150) NOT NULL,
    contact_person character varying(100) DEFAULT NULL::character varying,
    supplier_type character varying NOT NULL,
    phone character varying(50) DEFAULT NULL::character varying,
    email character varying(150) DEFAULT NULL::character varying,
    address character varying(255) DEFAULT NULL::character varying,
    status character varying DEFAULT 'active'::character varying
);

-- Name: suppliers_supplier_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.suppliers_supplier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: suppliers_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.suppliers_supplier_id_seq OWNED BY public.suppliers.supplier_id;

-- Name: users; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.users (
    user_id integer NOT NULL,
    company_id integer,
    username character varying(50) NOT NULL,
    full_name character varying(150) DEFAULT NULL::character varying,
    email character varying(150) DEFAULT NULL::character varying,
    phone character varying(50) DEFAULT NULL::character varying,
    password character varying(255) NOT NULL,
    login_code character varying(10) NOT NULL
);

-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;

-- Name: view_animal_profitability; Type: VIEW; Schema: public; Owner: -

CREATE VIEW public.view_animal_profitability WITH (security_invoker='true') AS
 SELECT a.animal_id,
    a.tag_number,
    COALESCE(( SELECT sum((df.quantity_kg * f.cost_per_kg)) AS sum
           FROM (public.daily_feeding df
             JOIN public.feed f ON ((df.feed_id = f.feed_id)))
          WHERE (df.animal_id = a.animal_id)), (0)::numeric) AS total_feeding_cost,
    COALESCE(( SELECT sum(oc.cost_value) AS sum
           FROM public.operational_costs oc
          WHERE (oc.animal_id = a.animal_id)), (0)::numeric) AS total_operational_cost,
    COALESCE(( SELECT sum(hr.cost) AS sum
           FROM public.health_records hr
          WHERE (hr.animal_id = a.animal_id)), (0)::numeric) AS total_health_cost,
    COALESCE(s.net_value, (0)::numeric) AS revenue,
    (COALESCE(s.net_value, (0)::numeric) - ((COALESCE(( SELECT sum((df.quantity_kg * f.cost_per_kg)) AS sum
           FROM (public.daily_feeding df
             JOIN public.feed f ON ((df.feed_id = f.feed_id)))
          WHERE (df.animal_id = a.animal_id)), (0)::numeric) + COALESCE(( SELECT sum(oc.cost_value) AS sum
           FROM public.operational_costs oc
          WHERE (oc.animal_id = a.animal_id)), (0)::numeric)) + COALESCE(( SELECT sum(hr.cost) AS sum
           FROM public.health_records hr
          WHERE (hr.animal_id = a.animal_id)), (0)::numeric))) AS net_profit
   FROM (public.animal a
     LEFT JOIN public.sales s ON ((a.animal_id = s.animal_id)));

-- Name: weighing; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.weighing (
    weighing_id integer NOT NULL,
    animal_id integer NOT NULL,
    weighing_date date NOT NULL,
    weight_kg numeric(10,2) NOT NULL,
    daily_gain numeric(10,2) DEFAULT NULL::numeric,
    source character varying(20) DEFAULT 'manual'::character varying NOT NULL,
    source_file character varying(255) DEFAULT NULL::character varying,
    source_device character varying(100) DEFAULT NULL::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    operation_id integer
);

-- Name: weighing_operations; Type: TABLE; Schema: public; Owner: -

CREATE TABLE public.weighing_operations (
    operation_id integer NOT NULL,
    operation_type character varying NOT NULL,
    operation_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    source_file character varying(255) DEFAULT NULL::character varying,
    records_count integer DEFAULT 0,
    user_id integer
);

-- Name: weighing_operations_operation_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.weighing_operations_operation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: weighing_operations_operation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.weighing_operations_operation_id_seq OWNED BY public.weighing_operations.operation_id;

-- Name: weighing_weighing_id_seq; Type: SEQUENCE; Schema: public; Owner: -

CREATE SEQUENCE public.weighing_weighing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- Name: weighing_weighing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -

ALTER SEQUENCE public.weighing_weighing_id_seq OWNED BY public.weighing.weighing_id;

-- Name: accounts_payable payable_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.accounts_payable ALTER COLUMN payable_id SET DEFAULT nextval('public.accounts_payable_payable_id_seq'::regclass);

-- Name: animal animal_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.animal ALTER COLUMN animal_id SET DEFAULT nextval('public.animal_animal_id_seq'::regclass);

-- Name: animal_types type_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.animal_types ALTER COLUMN type_id SET DEFAULT nextval('public.animal_types_type_id_seq'::regclass);

-- Name: clients client_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.clients ALTER COLUMN client_id SET DEFAULT nextval('public.clients_client_id_seq'::regclass);

-- Name: company company_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.company ALTER COLUMN company_id SET DEFAULT nextval('public.company_company_id_seq'::regclass);

-- Name: daily_feeding feeding_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.daily_feeding ALTER COLUMN feeding_id SET DEFAULT nextval('public.daily_feeding_feeding_id_seq'::regclass);

-- Name: european_countries country_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.european_countries ALTER COLUMN country_id SET DEFAULT nextval('public.european_countries_country_id_seq'::regclass);

-- Name: events event_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.events ALTER COLUMN event_id SET DEFAULT nextval('public.events_event_id_seq'::regclass);

-- Name: feed feed_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.feed ALTER COLUMN feed_id SET DEFAULT nextval('public.feed_feed_id_seq'::regclass);

-- Name: financial_categories category_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.financial_categories ALTER COLUMN category_id SET DEFAULT nextval('public.financial_categories_category_id_seq'::regclass);

-- Name: health_records record_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.health_records ALTER COLUMN record_id SET DEFAULT nextval('public.health_records_record_id_seq'::regclass);

-- Name: login_attempts id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.login_attempts ALTER COLUMN id SET DEFAULT nextval('public.login_attempts_id_seq'::regclass);

-- Name: lot lot_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.lot ALTER COLUMN lot_id SET DEFAULT nextval('public.lot_lot_id_seq'::regclass);

-- Name: market_prices price_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.market_prices ALTER COLUMN price_id SET DEFAULT nextval('public.market_prices_price_id_seq'::regclass);

-- Name: medical_catalog item_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.medical_catalog ALTER COLUMN item_id SET DEFAULT nextval('public.medical_catalog_item_id_seq'::regclass);

-- Name: operational_costs cost_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.operational_costs ALTER COLUMN cost_id SET DEFAULT nextval('public.operational_costs_cost_id_seq'::regclass);

-- Name: sales sale_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.sales ALTER COLUMN sale_id SET DEFAULT nextval('public.sales_sale_id_seq'::regclass);

-- Name: suppliers supplier_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.suppliers ALTER COLUMN supplier_id SET DEFAULT nextval('public.suppliers_supplier_id_seq'::regclass);

-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);

-- Name: weighing weighing_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.weighing ALTER COLUMN weighing_id SET DEFAULT nextval('public.weighing_weighing_id_seq'::regclass);

-- Name: weighing_operations operation_id; Type: DEFAULT; Schema: public; Owner: -

ALTER TABLE ONLY public.weighing_operations ALTER COLUMN operation_id SET DEFAULT nextval('public.weighing_operations_operation_id_seq'::regclass);

-- Data for Name: accounts_payable; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.accounts_payable VALUES
	(12, 1, 1, 4, 'Electricity Bill - Current Month', 'INV-NOW-01', 450.00, '2026-02-06', '2026-02-06', 'paid', NULL, '2026-02-08 16:55:26'),
	(13, 1, 3, 3, 'Manager Salary', 'SAL-001', 3200.00, '2026-02-08', '2026-02-08', 'paid', NULL, '2026-02-08 16:55:26'),
	(14, 1, 2, 1, 'Emergency Feed Stock', 'GLN-EMERG', 800.00, '2026-02-13', NULL, 'pending', NULL, '2026-02-08 16:55:26'),
	(15, 1, 1, 4, 'Electricity Bill - Last Month', 'INV-PREV-01', 420.00, '2026-01-08', '2026-01-08', 'paid', NULL, '2026-02-08 16:55:26'),
	(16, 1, 6, 5, 'Machinery Repair', 'FIX-OLD-99', 1500.00, '2026-01-08', '2026-01-08', 'paid', NULL, '2026-02-08 16:55:26'),
	(17, 2, 5, 6, 'Tractor Diesel', 'TOP-FUEL-22', 780.00, '2026-02-03', '2026-02-03', 'paid', NULL, '2026-02-08 16:55:26'),
	(18, 2, 4, 2, 'Vet Visit - Routine', 'VET-ROUTINE', 250.00, '2026-02-10', NULL, 'pending', NULL, '2026-02-08 16:55:26'),
	(19, 3, 7, 8, 'Quarterly Tax', 'TAX-Q1', 1200.00, '2026-02-23', NULL, 'pending', NULL, '2026-02-08 16:55:26'),
	(20, 7, 5, 2, 'Teste', NULL, 100.00, '2026-02-08', NULL, 'pending', NULL, '2026-02-08 16:58:40'),
	(21, 9, 5, 1, 'Feed', NULL, 250.00, '2026-02-08', NULL, 'pending', NULL, '2026-02-08 18:36:15');

-- Data for Name: animal; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.animal VALUES
	(31, 'IE 2111000', 5, '2024-12-08', '0', 14, 'male', 'sold'),
	(32, 'IE 2111001', 5, '2024-12-08', '0', 14, 'female', 'dead'),
	(33, 'IE 2111002', 5, '2024-11-08', 'Navan', 14, 'male', 'active'),
	(34, 'IE 2111003', 5, '2025-01-08', 'Trim', 14, 'male', 'active'),
	(35, 'IE 2111004', 5, '2024-10-08', 'Kells', 14, 'female', 'active'),
	(36, 'IE 2111005', 5, '2024-12-08', 'Navan', 14, 'male', 'active'),
	(37, 'IE 2111006', 5, '2024-11-08', 'Navan', 14, 'female', 'active'),
	(38, 'IE 2111007', 5, '2024-12-08', 'Trim', 14, 'male', 'active'),
	(39, 'IE 2111008', 5, '2025-01-08', 'Navan', 14, 'male', 'active'),
	(40, 'IE 2111009', 5, '2024-11-08', 'Navan', 14, 'female', 'active'),
	(41, 'IE 2111010', 5, '2024-12-08', 'Navan', 14, 'male', 'active'),
	(42, 'IE 2111011', 5, '2024-10-08', 'Trim', 14, 'male', 'active'),
	(43, 'IE 2111012', 5, '2024-12-08', 'Navan', 14, 'female', 'active'),
	(44, 'IE 2111013', 5, '2024-11-08', 'Navan', 14, 'male', 'sold'),
	(45, 'IE 2111014', 5, '2025-01-08', 'Kells', 14, 'male', 'active'),
	(46, 'IE 2111015', 5, '2024-12-08', 'Navan', 14, 'female', 'active'),
	(47, 'IE 2111016', 5, '2024-11-08', 'Navan', 14, 'male', 'active'),
	(48, 'IE 2111017', 5, '2024-12-08', 'Trim', 14, 'male', 'active'),
	(49, 'IE 2111018', 5, '2024-10-08', 'Navan', 14, 'female', 'active'),
	(50, 'IE 2111019', 5, '2024-12-08', 'Navan', 14, 'male', 'active'),
	(51, 'IE 2111020', 5, '2024-11-08', 'Navan', 14, 'male', 'active'),
	(52, 'IE 2111021', 5, '2025-01-08', 'Trim', 14, 'female', 'active'),
	(53, 'IE 2111022', 5, '2024-12-08', 'Navan', 14, 'male', 'active'),
	(54, 'IE 2111023', 5, '2024-11-08', 'Kells', 14, 'male', 'active'),
	(55, 'IE 2111024', 5, '2024-12-08', 'Navan', 14, 'female', 'active'),
	(56, 'IE 2111025', 5, '2024-10-08', 'Navan', 14, 'male', 'active'),
	(57, 'IE 2111026', 5, '2024-12-08', 'Trim', 14, 'male', 'active'),
	(58, 'IE 2111027', 5, '2024-11-08', 'Navan', 14, 'female', 'active'),
	(59, 'IE 2111028', 5, '2025-01-08', 'Navan', 14, 'male', 'active'),
	(60, 'IE 2111029', 5, '2024-12-08', '0', 14, 'male', 'dead'),
	(61, 'IE 2111200', 7, '2024-02-08', 'Drogheda', 14, 'male', 'active'),
	(62, 'IE 2111201', 7, '2024-03-08', 'Drogheda', 14, 'male', 'active'),
	(63, 'IE 2111202', 7, '2024-04-08', 'Drogheda', 14, 'male', 'active'),
	(64, 'IE 2111203', 7, '2024-02-08', 'Slane', 14, 'male', 'active'),
	(65, 'IE 2111204', 7, '2024-03-08', 'Slane', 14, 'male', 'active'),
	(66, 'IE 2111205', 7, '2024-04-08', 'Slane', 14, 'male', 'active'),
	(67, 'IE 2111206', 7, '2024-02-08', 'Drogheda', 14, 'male', 'active'),
	(68, 'IE 2111207', 7, '2024-03-08', 'Drogheda', 14, 'male', 'active'),
	(69, 'IE 2111208', 7, '2024-04-08', 'Drogheda', 14, 'male', 'active'),
	(70, 'IE 2111209', 7, '2024-02-08', 'Slane', 14, 'male', 'active'),
	(71, 'IE 2111210', 7, '2024-03-08', 'Slane', 14, 'male', 'active'),
	(72, 'IE 2111211', 7, '2024-04-08', 'Slane', 14, 'male', 'active'),
	(73, 'IE 2111212', 7, '2024-02-08', 'Drogheda', 14, 'male', 'active'),
	(74, 'IE 2111213', 7, '2024-03-08', 'Drogheda', 14, 'male', 'active'),
	(75, 'IE 2111214', 7, '2024-04-08', 'Drogheda', 14, 'male', 'active'),
	(76, 'IE 2111215', 7, '2024-02-08', 'Slane', 14, 'male', 'active'),
	(77, 'IE 2111216', 7, '2024-03-08', 'Slane', 14, 'male', 'active'),
	(78, 'IE 2111217', 7, '2024-04-08', 'Slane', 14, 'male', 'active'),
	(79, 'IE 2111218', 7, '2024-02-08', 'Drogheda', 14, 'male', 'active'),
	(80, 'IE 2111219', 7, '2024-03-08', 'Drogheda', 14, 'male', 'active'),
	(81, 'IE 2111220', 7, '2024-04-08', 'Drogheda', 14, 'male', 'active'),
	(82, 'IE 2111221', 7, '2024-02-08', 'Slane', 14, 'male', 'active'),
	(83, 'IE 2111222', 7, '2024-03-08', 'Slane', 14, 'male', 'active'),
	(84, 'IE 2111223', 7, '2024-04-08', 'Slane', 14, 'male', 'active'),
	(85, 'IE 2111224', 7, '2024-02-08', 'Drogheda', 14, 'male', 'active'),
	(86, 'IE 2111225', 7, '2024-03-08', 'Drogheda', 14, 'male', 'active'),
	(87, 'IE 2111226', 7, '2024-04-08', 'Drogheda', 14, 'male', 'active'),
	(88, 'IE 2111227', 7, '2024-02-08', 'Slane', 14, 'male', 'active'),
	(89, 'IE 2111228', 7, '2024-03-08', 'Slane', 14, 'male', 'active'),
	(90, 'IE 2111229', 7, '2024-04-08', 'Slane', 14, 'male', 'active'),
	(91, 'IE 2111300', 8, '2025-06-08', 'Navan', 14, 'female', 'active'),
	(92, 'IE 2111301', 8, '2025-05-08', 'Navan', 14, 'male', 'active'),
	(93, 'IE 2111302', 8, '2025-06-08', 'Navan', 14, 'female', 'active'),
	(94, 'IE 2111303', 8, '2025-07-08', 'Navan', 14, 'male', 'active'),
	(95, 'IE 2111304', 8, '2025-05-08', 'Navan', 14, 'female', 'active'),
	(96, 'IE 2111305', 8, '2025-06-08', 'Navan', 14, 'male', 'active'),
	(97, 'IE 2111306', 8, '2025-07-08', 'Navan', 14, 'female', 'active'),
	(98, 'IE 2111307', 8, '2025-05-08', 'Navan', 14, 'male', 'active'),
	(99, 'IE 2111308', 8, '2025-06-08', 'Navan', 14, 'female', 'active'),
	(100, 'IE 2111309', 8, '2025-07-08', 'Navan', 14, 'male', 'active'),
	(101, 'IE 2111310', 8, '2025-05-08', 'Navan', 14, 'female', 'active'),
	(102, 'IE 2111311', 8, '2025-06-08', 'Navan', 14, 'male', 'active'),
	(103, 'IE 2111312', 8, '2025-07-08', 'Navan', 14, 'female', 'active'),
	(104, 'IE 2111313', 8, '2025-05-08', 'Navan', 14, 'male', 'active'),
	(105, 'IE 2111314', 8, '2025-06-08', 'Navan', 14, 'female', 'active'),
	(106, 'IE 2111315', 8, '2025-07-08', 'Navan', 14, 'male', 'active'),
	(107, 'IE 2111316', 8, '2025-05-08', 'Navan', 14, 'female', 'active'),
	(108, 'IE 2111317', 8, '2025-06-08', 'Navan', 14, 'male', 'active'),
	(109, 'IE 2111318', 8, '2025-07-08', 'Navan', 14, 'female', 'active'),
	(110, 'IE 2111319', 8, '2025-05-08', '0', 14, 'male', 'sold'),
	(111, 'IE 30100', 6, '2025-10-08', 'Cork', 14, 'male', 'active'),
	(112, 'IE 30101', 6, '2025-10-08', 'Cork', 14, 'female', 'active'),
	(113, 'IE 30102', 6, '2025-10-08', 'Cork', 14, 'male', 'active'),
	(114, 'IE 30103', 6, '2025-10-08', 'Cork', 14, 'female', 'active'),
	(115, 'IE 30104', 6, '2025-10-08', 'Cork', 14, 'male', 'active'),
	(116, 'IE 30105', 6, '2025-10-08', 'Cork', 14, 'female', 'active'),
	(117, 'IE 30106', 6, '2025-10-08', 'Cork', 14, 'male', 'active'),
	(118, 'IE 30107', 6, '2025-10-08', 'Cork', 14, 'female', 'active'),
	(119, 'IE 30108', 6, '2025-10-08', 'Cork', 14, 'male', 'active'),
	(120, 'IE 30109', 6, '2025-10-08', 'Cork', 14, 'female', 'active'),
	(121, 'IE 30110', 6, '2025-10-08', 'Cork', 14, 'male', 'active'),
	(122, 'IE 30111', 6, '2025-10-08', 'Cork', 14, 'female', 'active'),
	(123, 'IE 30112', 6, '2025-10-08', 'Cork', 14, 'male', 'active'),
	(124, 'IE 30113', 6, '2025-10-08', 'Cork', 14, 'female', 'active'),
	(125, 'IE 30114', 6, '2025-10-08', 'Cork', 14, 'male', 'active'),
	(126, 'IE 30115', 6, '2025-10-08', 'Cork', 14, 'female', 'active'),
	(127, 'IE 30116', 6, '2025-10-08', 'Cork', 14, 'male', 'active'),
	(128, 'IE 30117', 6, '2025-10-08', 'Cork', 14, 'female', 'active'),
	(129, 'IE 30118', 6, '2025-10-08', 'Cork', 14, 'male', 'active'),
	(130, 'IE 30119', 6, '2025-10-08', 'Cork', 14, 'female', 'active'),
	(131, 'IE 20100', 6, '2024-02-08', 'Galway', 14, 'male', 'sold'),
	(132, 'IE 20101', 6, '2024-02-08', 'Galway', 14, 'female', 'active'),
	(133, 'IE 20102', 6, '2024-02-08', 'Galway', 14, 'male', 'active'),
	(134, 'IE 20103', 6, '2024-02-08', 'Galway', 14, 'female', 'active'),
	(135, 'IE 20104', 6, '2024-02-08', 'Galway', 14, 'male', 'active'),
	(136, 'IE 20105', 6, '2024-02-08', 'Galway', 14, 'female', 'active'),
	(137, 'IE 20106', 6, '2024-02-08', 'Galway', 14, 'male', 'active'),
	(138, 'IE 20107', 6, '2024-02-08', 'Galway', 14, 'female', 'active'),
	(139, 'IE 20108', 6, '2024-02-08', 'Galway', 14, 'male', 'active'),
	(140, 'IE 20109', 6, '2024-02-08', 'Galway', 14, 'female', 'active'),
	(141, 'IE 20110', 6, '2024-02-08', 'Galway', 14, 'male', 'active'),
	(142, 'IE 20111', 6, '2024-02-08', 'Galway', 14, 'female', 'active'),
	(143, 'IE 20112', 6, '2024-02-08', 'Galway', 14, 'male', 'active'),
	(144, 'IE 20113', 6, '2024-02-08', 'Galway', 14, 'female', 'active'),
	(145, 'IE 20114', 6, '2024-02-08', 'Galway', 14, 'male', 'active'),
	(146, 'IE 30200', 6, '2024-06-08', 'Cork', 14, 'male', 'active'),
	(147, 'IE 30201', 6, '2024-05-08', 'Cork', 14, 'male', 'active'),
	(148, 'IE 30202', 6, '2024-06-08', 'Cork', 14, 'male', 'active'),
	(149, 'IE 30203', 6, '2024-05-08', 'Cork', 14, 'male', 'active'),
	(150, 'IE 30204', 6, '2024-06-08', 'Cork', 14, 'male', 'active'),
	(151, 'IE 30205', 6, '2024-05-08', 'Cork', 14, 'male', 'active'),
	(152, 'IE 30206', 6, '2024-06-08', 'Cork', 14, 'male', 'active'),
	(153, 'IE 30207', 6, '2024-05-08', 'Cork', 14, 'male', 'active'),
	(154, 'IE 30208', 6, '2024-06-08', 'Cork', 14, 'male', 'active'),
	(155, 'IE 30209', 6, '2024-05-08', 'Cork', 14, 'male', 'active'),
	(156, 'IE 30210', 5, '2024-06-08', 'Cork', 14, 'male', 'active'),
	(157, 'IE 30211', 5, '2024-05-08', 'Cork', 14, 'male', 'active'),
	(158, 'IE 30212', 5, '2024-06-08', 'Cork', 14, 'male', 'active'),
	(159, 'IE 30213', 5, '2024-05-08', 'Cork', 14, 'male', 'active'),
	(160, 'IE 30214', 5, '2024-06-08', 'Cork', 14, 'male', 'active'),
	(161, 'IE 30215', 5, '2024-05-08', 'Cork', 14, 'male', 'active'),
	(162, 'IE 30216', 5, '2024-06-08', 'Cork', 14, 'male', 'active'),
	(163, 'IE 30217', 5, '2024-05-08', 'Cork', 14, 'male', 'active'),
	(164, 'IE 30218', 5, '2024-06-08', 'Cork', 14, 'male', 'active'),
	(165, 'IE 30219', 5, '2024-05-08', 'Cork', 14, 'male', 'active'),
	(166, 'IE 40100', 8, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(167, 'IE 40101', 8, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(168, 'IE 40102', 8, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(169, 'IE 40103', 8, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(170, 'IE 40104', 8, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(171, 'IE 40105', 8, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(172, 'IE 40106', 8, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(173, 'IE 40107', 8, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(174, 'IE 40108', 8, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(175, 'IE 40109', 8, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(176, 'IE 40110', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(177, 'IE 40111', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(178, 'IE 40112', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(179, 'IE 40113', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(180, 'IE 40114', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(181, 'IE 40115', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(182, 'IE 40116', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(183, 'IE 40117', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(184, 'IE 40118', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(185, 'IE 40119', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(186, 'IE 40120', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(187, 'IE 40121', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(188, 'IE 40122', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(189, 'IE 40123', 9, '2024-08-08', 'Wexford', 14, 'female', 'active'),
	(190, 'IE 40124', 9, '2024-08-08', '0', 14, 'female', 'dead');

-- Data for Name: animal_types; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.animal_types VALUES
	(5, 'cattle', 'Aberdeen Angus', 'Code: AA | Origin: Scotland | Avg Weight: 650-1000kg | Gestation: 283 days. Famous for high marbling, early maturity, and easy calving. Extremely popular in Ireland.'),
	(6, 'cattle', 'Hereford', 'Code: HE | Origin: England | Avg Weight: 600-1000kg | Gestation: 284 days. Docile temperament, excellent grass conversion, and hardy in winter conditions.'),
	(7, 'cattle', 'Charolais', 'Code: CH | Origin: France | Avg Weight: 800-1200kg | Gestation: 289 days. Top terminal sire for weight gain. Produces heavy, muscular carcasses for export.'),
	(8, 'cattle', 'Limousin', 'Code: LM | Origin: France | Avg Weight: 700-1100kg | Gestation: 289 days. Balanced breed offering lean meat, high killing-out percentage, and good calving ease.'),
	(9, 'cattle', 'Simmental', 'Code: SI | Origin: Switzerland | Avg Weight: 750-1150kg | Gestation: 287 days. Dual-purpose heritage. Cows have excellent milk supply, weaning heavy calves.'),
	(10, 'cattle', 'Belgian Blue', 'Code: BB | Origin: Belgium | Avg Weight: 700-1100kg | Gestation: 286 days. Known for double-muscling trait. Extreme carcass yield and very lean meat.');

-- Data for Name: clients; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.clients VALUES
	(1, 1, 'Liam O''Sullivan', 'IE1234567A', 'liam@dublintech.ie', '+353 1 445 6789', 'Grafton St, Dublin 2'),
	(2, 2, 'Siobhan Murphy', 'IE2345678B', 'siobhan@corkdairy.ie', '+353 21 765 4321', 'Grand Parade, Cork'),
	(3, 1, 'Connor Kelly', 'IE3456789C', 'connor@dublintech.ie', '+353 1 223 3344', 'Silicon Docks, Dublin 4'),
	(4, 3, 'Aoife Walsh', 'IE4567890D', 'aoife@galwayagri.ie', '+353 91 556 778', 'Eyre Square, Galway'),
	(5, 2, 'Patrick Byrne', 'IE5678901E', 'patrick@corkdairy.ie', '+353 21 998 112', 'Blackrock, Cork'),
	(6, 4, 'Saoirse O''Connor', 'IE6789012F', 'saoirse@limerickbio.ie', '+353 61 334 556', 'O''Connell St, Limerick'),
	(7, 5, 'Cillian Ryan', 'IE7890123G', 'cillian@kerrylogistics.ie', '+353 66 778 889', 'Tralee Road, Killarney'),
	(8, 1, 'Roisin McCarthy', 'IE8901234H', 'roisin@dublintech.ie', '+353 1 667 8890', 'Merrion Square, Dublin 2'),
	(9, 3, 'Darragh O''Brien', 'IE9012345I', 'darragh@galwayagri.ie', '+353 91 443 221', 'Salthill, Galway'),
	(10, 6, 'Niamh Kennedy', 'IE0123456J', 'niamh@wicklowsheep.ie', '+353 404 12345', 'Bray Promenade, Wicklow'),
	(11, 4, 'Eoin Higgins', 'IE1122334K', 'eoin@limerickbio.ie', '+353 61 778 990', 'Castletroy, Limerick'),
	(12, 7, 'Aisling Quinn', 'IE2233445L', 'aisling@donegalfish.ie', '+353 74 912 345', 'Diamond, Donegal Town'),
	(13, 2, 'Fionn Gallagher', 'IE3344556M', 'fionn@corkdairy.ie', '+353 21 445 556', 'Kinsale Rd, Cork'),
	(14, 5, 'Ciara Whelan', 'IE4455667N', 'ciara@kerrylogistics.ie', '+353 66 112 233', 'Main St, Dingle'),
	(15, 8, 'Brendan Lynch', 'IE5566778O', 'brendan@waterfordglass.ie', '+353 51 889 001', 'Viking Triangle, Waterford'),
	(16, 1, 'Orla Brady', 'IE6677889P', 'orla@dublintech.ie', '+353 1 990 112', 'Howth Rd, Dublin 13'),
	(17, 6, 'Sean Power', 'IE7788990Q', 'sean@wicklowsheep.ie', '+353 404 998 77', 'Glendalough, Wicklow'),
	(18, 4, 'Maeve Dunne', 'IE8899001R', 'maeve@limerickbio.ie', '+353 61 112 334', 'Dooradoyle, Limerick'),
	(19, 9, 'Diarmuid Flynn', 'IE9900112S', 'diarmuid@tipphorse.ie', '+353 52 445 667', 'Cashel, Tipperary'),
	(20, 10, 'Grainne Doyle', 'IE0011223T', 'grainne@meathheritage.ie', '+353 46 901 223', 'Navan, Meath');

-- Data for Name: company; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.company VALUES
	(5, 'Green Valley Farm', 'Green Valley Farm (Demo)', 'IE0000000X', 'Demo Farmer', 'Co. Limerick, Ireland', '+353 61 000 000', 'demo@example.com', 'uploads/1770551869_69887a3d706f8.png', '2026-02-08 11:57:31'),
	(6, 'Emerald Hill Livestock', 'Emerald Beef Producers Ltd', 'IE6543210A', 'Patrick O''Sullivan', 'Ballymaloe, Shanagarry, Co. Cork', '+353 87 555 1234', 'contact@emeraldbeef.ie', 'assets/img/logos/logo_cork.png', '2026-02-08 12:28:28'),
	(7, 'Corrib Pastures', 'Corrib Agri-Business', 'IE7788990B', 'Sorcha Kelly', 'Oughterard, Connemara, Co. Galway', '+353 86 111 2233', 'info@corribpastures.com', 'assets/img/logos/logo_galway.png', '2026-02-08 12:28:28'),
	(8, 'Slaney River Beef', 'Slaney Livestock Producers', 'IE3344556C', 'Seamus Murphy', 'Enniscorthy, Co. Wexford', '+353 83 999 8877', 'sales@slaneybeef.ie', 'assets/img/logos/logo_wexford.png', '2026-02-08 12:28:28'),
	(9, 'Boyne Valley Stock Farm', 'Boyne Valley Meats Ltd', 'IE1122334D', 'Ciaran Byrne', 'Navan, Co. Meath', '+353 85 444 6655', 'admin@boynevalley.ie', 'uploads/1770553734_6988818663a70.webp', '2026-02-08 12:28:28');

-- Data for Name: daily_feeding; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.daily_feeding VALUES
	(1, 31, 3, '2026-02-08', 1.67),
	(2, 32, 3, '2026-02-08', 1.67),
	(3, 33, 3, '2026-02-08', 1.67),
	(4, 34, 3, '2026-02-08', 1.67),
	(5, 35, 3, '2026-02-08', 1.67),
	(6, 36, 3, '2026-02-08', 1.67),
	(7, 37, 3, '2026-02-08', 1.67),
	(8, 38, 3, '2026-02-08', 1.67),
	(9, 39, 3, '2026-02-08', 1.67),
	(10, 40, 3, '2026-02-08', 1.67),
	(11, 41, 3, '2026-02-08', 1.67),
	(12, 42, 3, '2026-02-08', 1.67),
	(13, 43, 3, '2026-02-08', 1.67),
	(14, 44, 3, '2026-02-08', 1.67),
	(15, 45, 3, '2026-02-08', 1.67),
	(16, 46, 3, '2026-02-08', 1.67),
	(17, 47, 3, '2026-02-08', 1.67),
	(18, 48, 3, '2026-02-08', 1.67),
	(19, 49, 3, '2026-02-08', 1.67),
	(20, 50, 3, '2026-02-08', 1.67),
	(21, 51, 3, '2026-02-08', 1.67),
	(22, 52, 3, '2026-02-08', 1.67),
	(23, 53, 3, '2026-02-08', 1.67),
	(24, 54, 3, '2026-02-08', 1.67),
	(25, 55, 3, '2026-02-08', 1.67),
	(26, 56, 3, '2026-02-08', 1.67),
	(27, 57, 3, '2026-02-08', 1.67),
	(28, 58, 3, '2026-02-08', 1.67),
	(29, 59, 3, '2026-02-08', 1.67),
	(30, 60, 3, '2026-02-08', 1.67),
	(31, 146, 1, '2026-02-08', 2.50),
	(32, 147, 1, '2026-02-08', 2.50),
	(33, 148, 1, '2026-02-08', 2.50),
	(34, 149, 1, '2026-02-08', 2.50),
	(35, 150, 1, '2026-02-08', 2.50),
	(36, 151, 1, '2026-02-08', 2.50),
	(37, 152, 1, '2026-02-08', 2.50),
	(38, 153, 1, '2026-02-08', 2.50),
	(39, 154, 1, '2026-02-08', 2.50),
	(40, 155, 1, '2026-02-08', 2.50),
	(41, 156, 1, '2026-02-08', 2.50),
	(42, 157, 1, '2026-02-08', 2.50),
	(43, 158, 1, '2026-02-08', 2.50),
	(44, 159, 1, '2026-02-08', 2.50),
	(45, 160, 1, '2026-02-08', 2.50),
	(46, 161, 1, '2026-02-08', 2.50),
	(47, 162, 1, '2026-02-08', 2.50),
	(48, 163, 1, '2026-02-08', 2.50),
	(49, 164, 1, '2026-02-08', 2.50),
	(50, 165, 1, '2026-02-08', 2.50);

-- Data for Name: european_countries; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.european_countries VALUES
	(33, 'Albania'),
	(1, 'Austria'),
	(2, 'Belgium'),
	(35, 'Bosnia and Herzegovina'),
	(3, 'Bulgaria'),
	(4, 'Croatia'),
	(5, 'Cyprus'),
	(6, 'Czech Republic'),
	(7, 'Denmark'),
	(8, 'Estonia'),
	(9, 'Finland'),
	(10, 'France'),
	(11, 'Germany'),
	(12, 'Greece'),
	(13, 'Hungary'),
	(31, 'Iceland'),
	(14, 'Ireland'),
	(15, 'Italy'),
	(37, 'Kosovo'),
	(16, 'Latvia'),
	(17, 'Lithuania'),
	(18, 'Luxembourg'),
	(19, 'Malta'),
	(39, 'Moldova'),
	(34, 'Montenegro'),
	(20, 'Netherlands'),
	(36, 'North Macedonia'),
	(29, 'Norway'),
	(21, 'Poland'),
	(22, 'Portugal'),
	(23, 'Romania'),
	(32, 'Serbia'),
	(24, 'Slovakia'),
	(25, 'Slovenia'),
	(26, 'Spain'),
	(27, 'Sweden'),
	(30, 'Switzerland'),
	(38, 'Ukraine'),
	(28, 'United Kingdom');

-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: -

-- Data for Name: feed; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.feed VALUES
	(1, 'Premium Beef Mix', 'High protein feed for beef cattle', 18.50, 1.60, NULL),
	(2, 'Growth Starter', 'Young cattle starter feed', 16.00, 1.20, NULL),
	(3, 'Vitamin Mix', 'Mineral and vitamin supplement', 0.00, 0.90, NULL);

-- Data for Name: financial_categories; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.financial_categories VALUES
	(1, 'Feed & Nutrition', 'revenue'),
	(2, 'Animal Health & Vet', 'revenue'),
	(3, 'Labor & Salaries', 'revenue'),
	(4, 'Energy & Utilities', 'revenue'),
	(5, 'Machinery Maintenance', 'revenue'),
	(6, 'Fuel & Logistics', 'revenue'),
	(7, 'Infrastructure & Fencing', 'revenue'),
	(8, 'Taxes & Levies', 'revenue');

-- Data for Name: health_records; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.health_records VALUES
	(1, 31, 11, '2025-10-11', 'Farm Manager', 'Routine Winter Dosing (Fluke & Worms)', 4.50, '2026-02-08 12:48:27'),
	(2, 31, 2, '2025-11-10', 'Dr. Liam O''Connor', 'IBR Vaccination Booster', 3.25, '2026-02-08 12:48:27'),
	(3, 31, 25, '2026-01-09', 'Dr. Liam O''Connor', 'Lameness - Digital Dermatitis treated', 85.00, '2026-02-08 12:48:27'),
	(4, 31, 16, '2026-01-09', 'Dr. Liam O''Connor', 'Antibiotic Injection (Hexasol)', 12.00, '2026-02-08 12:48:27'),
	(5, 111, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(6, 112, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(7, 113, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(8, 114, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(9, 115, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(10, 116, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(11, 117, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(12, 118, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(13, 119, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(14, 120, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(15, 121, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(16, 122, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(17, 123, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(18, 124, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(19, 125, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(20, 126, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(21, 127, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(22, 128, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(23, 129, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(24, 130, 4, '2025-12-10', 'Farm Manager', 'Clostridial Vaccine (Blackleg) - Primary Course', 2.80, '2026-02-08 12:48:27'),
	(36, 131, 10, '2026-01-24', 'Farm Manager', 'External Parasite Control (Lice)', 1.50, '2026-02-08 12:48:27'),
	(37, 132, 10, '2026-01-24', 'Farm Manager', 'External Parasite Control (Lice)', 1.50, '2026-02-08 12:48:27'),
	(38, 133, 10, '2026-01-24', 'Farm Manager', 'External Parasite Control (Lice)', 1.50, '2026-02-08 12:48:27'),
	(39, 134, 10, '2026-01-24', 'Farm Manager', 'External Parasite Control (Lice)', 1.50, '2026-02-08 12:48:27'),
	(40, 135, 10, '2026-01-24', 'Farm Manager', 'External Parasite Control (Lice)', 1.50, '2026-02-08 12:48:27'),
	(41, 136, 10, '2026-01-24', 'Farm Manager', 'External Parasite Control (Lice)', 1.50, '2026-02-08 12:48:27'),
	(42, 137, 10, '2026-01-24', 'Farm Manager', 'External Parasite Control (Lice)', 1.50, '2026-02-08 12:48:27'),
	(43, 138, 10, '2026-01-24', 'Farm Manager', 'External Parasite Control (Lice)', 1.50, '2026-02-08 12:48:27'),
	(44, 139, 10, '2026-01-24', 'Farm Manager', 'External Parasite Control (Lice)', 1.50, '2026-02-08 12:48:27'),
	(45, 140, 10, '2026-01-24', 'Farm Manager', 'External Parasite Control (Lice)', 1.50, '2026-02-08 12:48:27'),
	(46, 141, 10, '2026-01-24', 'Farm Manager', 'External Parasite Control (Lice)', 1.50, '2026-02-08 12:48:27'),
	(51, 61, 28, '2026-01-29', 'Dr. Sarah Byrne (Dept Ag)', 'Annual TB Test - Clear', 4.50, '2026-02-08 12:48:27'),
	(52, 62, 28, '2026-01-29', 'Dr. Sarah Byrne (Dept Ag)', 'Annual TB Test - Clear', 4.50, '2026-02-08 12:48:27'),
	(53, 63, 28, '2026-01-29', 'Dr. Sarah Byrne (Dept Ag)', 'Annual TB Test - Clear', 4.50, '2026-02-08 12:48:27'),
	(54, 64, 28, '2026-01-29', 'Dr. Sarah Byrne (Dept Ag)', 'Annual TB Test - Clear', 4.50, '2026-02-08 12:48:27'),
	(55, 65, 28, '2026-01-29', 'Dr. Sarah Byrne (Dept Ag)', 'Annual TB Test - Clear', 4.50, '2026-02-08 12:48:27'),
	(56, 66, 28, '2026-01-29', 'Dr. Sarah Byrne (Dept Ag)', 'Annual TB Test - Clear', 4.50, '2026-02-08 12:48:27'),
	(57, 67, 28, '2026-01-29', 'Dr. Sarah Byrne (Dept Ag)', 'Annual TB Test - Clear', 4.50, '2026-02-08 12:48:27'),
	(58, 68, 28, '2026-01-29', 'Dr. Sarah Byrne (Dept Ag)', 'Annual TB Test - Clear', 4.50, '2026-02-08 12:48:27'),
	(59, 69, 28, '2026-01-29', 'Dr. Sarah Byrne (Dept Ag)', 'Annual TB Test - Clear', 4.50, '2026-02-08 12:48:27'),
	(60, 70, 28, '2026-01-29', 'Dr. Sarah Byrne (Dept Ag)', 'Annual TB Test - Clear', 4.50, '2026-02-08 12:48:27'),
	(61, 71, 28, '2026-01-29', 'Dr. Sarah Byrne (Dept Ag)', 'Annual TB Test - Clear', 4.50, '2026-02-08 12:48:27'),
	(66, 116, 25, '2026-02-03', 'Dr. Liam O''Connor', 'Acute Pneumonia Diagnosis', 60.00, '2026-02-08 12:48:27'),
	(67, 116, 16, '2026-02-03', 'Dr. Liam O''Connor', 'Antibiotic Treatment (Hexasol)', 15.00, '2026-02-08 12:48:27'),
	(68, 81, NULL, '2026-02-06', 'Farm Manager', 'Ringworm spray application', 0.50, '2026-02-08 12:48:27'),
	(69, 31, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(70, 32, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(71, 33, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(72, 34, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(73, 35, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(74, 36, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(75, 37, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(76, 38, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(77, 39, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(78, 40, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(79, 41, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(80, 42, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(81, 43, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(82, 44, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(83, 45, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(84, 46, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(85, 47, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(86, 48, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(87, 49, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(88, 50, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(89, 51, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(90, 52, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(91, 53, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(92, 54, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(93, 55, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(94, 56, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(95, 57, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(96, 58, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(97, 59, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(98, 60, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(99, 111, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(100, 112, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(101, 113, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(102, 114, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(103, 115, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(104, 116, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(105, 117, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(106, 118, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(107, 119, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(108, 120, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(109, 121, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(110, 122, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(111, 123, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(112, 124, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(113, 125, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(114, 126, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(115, 127, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(116, 128, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(117, 129, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(118, 130, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(119, 131, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(120, 132, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(121, 133, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(122, 134, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(123, 135, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(124, 136, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(125, 137, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(126, 138, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(127, 139, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(128, 140, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(129, 141, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(130, 142, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(131, 143, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(132, 144, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(133, 145, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(134, 61, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(135, 62, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(136, 63, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(137, 64, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(138, 65, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(139, 66, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(140, 67, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(141, 68, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(142, 69, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(143, 70, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(144, 71, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(145, 72, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(146, 73, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(147, 74, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(148, 75, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(149, 76, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(150, 77, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(151, 78, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(152, 79, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(153, 80, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(154, 81, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(155, 82, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(156, 83, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(157, 84, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(158, 85, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(159, 86, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(160, 87, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(161, 88, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(162, 89, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(163, 90, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(164, 91, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(165, 92, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(166, 93, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(167, 94, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(168, 95, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(169, 96, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(170, 97, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(171, 98, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(172, 99, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(173, 100, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(174, 101, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(175, 102, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(176, 103, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(177, 104, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(178, 105, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(179, 106, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(180, 107, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(181, 108, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(182, 109, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(183, 110, 10, '2025-10-08', 'Farm Manager', 'Routine Winter Housing Dose. Method: Pour-On along spine. Target: Lice & Mange prevention.', 2.50, '2026-02-08 12:50:58'),
	(196, 31, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(197, 32, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(198, 33, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(199, 34, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(200, 35, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(201, 36, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(202, 37, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(203, 38, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(204, 39, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(205, 40, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(206, 41, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(207, 42, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(208, 43, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(209, 44, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(210, 45, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(211, 46, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(212, 47, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(213, 48, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(214, 49, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(215, 50, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(216, 51, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(217, 52, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(218, 53, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(219, 54, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(220, 55, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(221, 56, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(222, 57, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(223, 58, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(224, 59, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(225, 60, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(226, 111, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(227, 112, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(228, 113, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(229, 114, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(230, 115, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(231, 116, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58');
INSERT INTO public.health_records VALUES
	(232, 117, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(233, 118, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(234, 119, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(235, 120, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(236, 121, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(237, 122, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(238, 123, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(239, 124, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(240, 125, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(241, 126, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(242, 127, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(243, 128, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(244, 129, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(245, 130, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(246, 131, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(247, 132, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(248, 133, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(249, 134, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(250, 135, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(251, 136, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(252, 137, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(253, 138, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(254, 139, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(255, 140, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(256, 141, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(257, 142, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(258, 143, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(259, 144, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(260, 145, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(261, 61, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(262, 62, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(263, 63, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(264, 64, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(265, 65, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(266, 66, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(267, 67, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(268, 68, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(269, 69, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(270, 70, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(271, 71, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(272, 72, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(273, 73, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(274, 74, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(275, 75, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(276, 76, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(277, 77, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(278, 78, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(279, 79, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(280, 80, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(281, 81, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(282, 82, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(283, 83, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(284, 84, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(285, 85, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(286, 86, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(287, 87, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(288, 88, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(289, 89, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(290, 90, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(291, 91, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(292, 92, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(293, 93, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(294, 94, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(295, 95, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(296, 96, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(297, 97, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(298, 98, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(299, 99, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(300, 100, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(301, 101, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(302, 102, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(303, 103, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(304, 104, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(305, 105, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(306, 106, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(307, 107, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(308, 108, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(309, 109, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(310, 110, 2, '2026-01-08', 'Dr. Liam O''Connor', 'Annual Herd Vaccination (IBR Marker). Method: Intramuscular Injection (Neck).', 4.20, '2026-02-08 12:50:58'),
	(323, 91, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(324, 92, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(325, 93, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(326, 94, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(327, 95, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(328, 96, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(329, 97, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(330, 98, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(331, 99, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(332, 100, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(333, 101, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(334, 102, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(335, 103, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(336, 104, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(337, 105, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(338, 106, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(339, 107, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(340, 108, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(341, 109, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(342, 110, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(343, 111, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(344, 112, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(345, 113, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(346, 114, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(347, 115, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(348, 116, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(349, 117, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(350, 118, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(351, 119, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(352, 120, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(353, 121, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(354, 122, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(355, 123, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(356, 124, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(357, 125, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(358, 126, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(359, 127, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(360, 128, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(361, 129, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(362, 130, 8, '2025-12-08', 'Farm Manager', 'Stomach Worm Control for young stock. Method: Oral Drench (Dose Gun).', 1.80, '2026-02-08 12:50:58'),
	(386, 76, 13, '2026-01-24', 'Dr. Liam O''Connor', 'Acute Respiratory Infection. Method: Deep Intramuscular Injection. Animal isolated for 3 days.', 18.50, '2026-02-08 12:50:58'),
	(387, 59, 13, '2026-01-24', 'Dr. Liam O''Connor', 'Acute Respiratory Infection. Method: Deep Intramuscular Injection. Animal isolated for 3 days.', 18.50, '2026-02-08 12:50:58'),
	(388, 69, 13, '2026-01-24', 'Dr. Liam O''Connor', 'Acute Respiratory Infection. Method: Deep Intramuscular Injection. Animal isolated for 3 days.', 18.50, '2026-02-08 12:50:58'),
	(389, 57, 13, '2026-01-24', 'Dr. Liam O''Connor', 'Acute Respiratory Infection. Method: Deep Intramuscular Injection. Animal isolated for 3 days.', 18.50, '2026-02-08 12:50:58'),
	(390, 101, 13, '2026-01-24', 'Dr. Liam O''Connor', 'Acute Respiratory Infection. Method: Deep Intramuscular Injection. Animal isolated for 3 days.', 18.50, '2026-02-08 12:50:58'),
	(391, 40, 13, '2026-01-24', 'Dr. Liam O''Connor', 'Acute Respiratory Infection. Method: Deep Intramuscular Injection. Animal isolated for 3 days.', 18.50, '2026-02-08 12:50:58'),
	(392, 38, 13, '2026-01-24', 'Dr. Liam O''Connor', 'Acute Respiratory Infection. Method: Deep Intramuscular Injection. Animal isolated for 3 days.', 18.50, '2026-02-08 12:50:58'),
	(393, 81, 13, '2026-01-24', 'Dr. Liam O''Connor', 'Acute Respiratory Infection. Method: Deep Intramuscular Injection. Animal isolated for 3 days.', 18.50, '2026-02-08 12:50:58'),
	(394, 32, 13, '2026-01-24', 'Dr. Liam O''Connor', 'Acute Respiratory Infection. Method: Deep Intramuscular Injection. Animal isolated for 3 days.', 18.50, '2026-02-08 12:50:58'),
	(395, 122, 13, '2026-01-24', 'Dr. Liam O''Connor', 'Acute Respiratory Infection. Method: Deep Intramuscular Injection. Animal isolated for 3 days.', 18.50, '2026-02-08 12:50:58'),
	(396, 189, 18, '2026-02-09', 'Chanelle Pharma', 'test', 65.00, '2026-02-09 13:05:59');

-- Data for Name: login_attempts; Type: TABLE DATA; Schema: public; Owner: -

-- Data for Name: lot; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.lot VALUES
	(5, 5, 'LOTE ALPHA', '2026-02-08', 'Farm Limerick'),
	(6, 9, 'Reception & Quarantine', '2026-02-08', 'Isolation area for newly arrived livestock (Biosecurity: 21 days).'),
	(7, 9, 'Weanlings (6-12m)', '2025-12-08', 'Weaned calves adapting to solid diet and initial grazing.'),
	(8, 9, 'Yearlings - Pasture A', '2025-08-08', 'Cattle aged 12-18 months on rotational grazing system.'),
	(9, 9, 'Finishing Barn 1 (Intensive)', '2025-11-08', 'Indoor finishing unit with high-grain diet (Final 90 days).'),
	(10, 9, 'Finishing Barn 2 (Overflow)', '2025-11-08', 'Supplementary housing for peak season finishing stock.'),
	(11, 9, 'Certified Angus Premium', '2026-01-08', 'Exclusive lot for certified Aberdeen Angus cattle (Quality Bonus scheme).'),
	(12, 9, 'Export Quarantine (EU)', '2026-02-08', 'Finished stock awaiting sanitary documentation for continental export.'),
	(13, 9, 'Hospital / Sick Bay', '2025-02-08', 'Sanitary area dedicated to the treatment of sick or injured animals.'),
	(14, 7, 'Hill Grazing (General)', '2025-09-08', 'Main mixed herd kept on native mountain pasture.'),
	(15, 7, 'Winter Shelter', '2026-01-08', 'Protective housing for vulnerable stock during severe winter weather.'),
	(16, 6, 'Spring Born Calves', '2025-10-08', 'Calves born in spring, focused on skeletal development.'),
	(17, 6, 'Grass-Fed Finishing', '2025-12-08', 'Cattle finishing exclusively on pasture (Green Ireland standard).'),
	(18, 6, 'Cull Cows', '2026-01-08', 'Cull cows on rapid fattening diet for slaughter.'),
	(19, 6, 'Bull Beef', '2025-11-08', 'Entire males in accelerated growth system (16-month target).'),
	(20, 8, 'Heifers', '2025-11-08', 'Group of young females for replacement or light finishing.'),
	(21, 8, 'Continental Crosses', '2025-12-08', 'Commercial crossbred lot (Charolais/Limousin) for high carcass yield.'),
	(22, 8, 'Pre-Sale Holding', '2026-02-08', 'Heavy sorted animals ready for dispatch to mart or factory.');

-- Data for Name: lot_animals; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.lot_animals VALUES
	(7, 91, '2026-02-08', NULL),
	(7, 92, '2026-02-08', NULL),
	(7, 93, '2026-02-08', NULL),
	(7, 94, '2026-02-08', NULL),
	(7, 95, '2026-02-08', NULL),
	(7, 96, '2026-02-08', NULL),
	(7, 97, '2026-02-08', NULL),
	(7, 98, '2026-02-08', NULL),
	(7, 99, '2026-02-08', NULL),
	(7, 100, '2026-02-08', NULL),
	(7, 101, '2026-02-08', NULL),
	(7, 102, '2026-02-08', NULL),
	(7, 103, '2026-02-08', NULL),
	(7, 104, '2026-02-08', NULL),
	(7, 105, '2026-02-08', NULL),
	(7, 106, '2026-02-08', NULL),
	(7, 107, '2026-02-08', NULL),
	(7, 108, '2026-02-08', NULL),
	(7, 109, '2026-02-08', NULL),
	(7, 110, '2026-02-08', NULL),
	(9, 61, '2025-12-08', NULL),
	(9, 62, '2025-12-08', NULL),
	(9, 63, '2025-12-08', NULL),
	(9, 64, '2025-12-08', NULL),
	(9, 65, '2025-12-08', NULL),
	(9, 66, '2025-12-08', NULL),
	(9, 67, '2025-12-08', NULL),
	(9, 68, '2025-12-08', NULL),
	(9, 69, '2025-12-08', NULL),
	(9, 70, '2025-12-08', NULL),
	(9, 71, '2025-12-08', NULL),
	(9, 72, '2025-12-08', NULL),
	(9, 73, '2025-12-08', NULL),
	(9, 74, '2025-12-08', NULL),
	(9, 75, '2025-12-08', NULL),
	(9, 76, '2025-12-08', NULL),
	(9, 77, '2025-12-08', NULL),
	(9, 78, '2025-12-08', NULL),
	(9, 79, '2025-12-08', NULL),
	(9, 80, '2025-12-08', NULL),
	(9, 81, '2025-12-08', NULL),
	(9, 82, '2025-12-08', NULL),
	(9, 83, '2025-12-08', NULL),
	(9, 84, '2025-12-08', NULL),
	(9, 85, '2025-12-08', NULL),
	(9, 86, '2025-12-08', NULL),
	(9, 87, '2025-12-08', NULL),
	(9, 88, '2025-12-08', NULL),
	(9, 89, '2025-12-08', NULL),
	(9, 90, '2025-12-08', NULL),
	(11, 31, '2026-02-08', NULL),
	(11, 32, '2026-02-08', NULL),
	(11, 33, '2026-02-08', NULL),
	(11, 34, '2026-02-08', NULL),
	(11, 35, '2026-02-08', NULL),
	(11, 36, '2026-02-08', NULL),
	(11, 37, '2026-02-08', NULL),
	(11, 38, '2026-02-08', NULL),
	(11, 39, '2026-02-08', NULL),
	(11, 40, '2026-02-08', NULL),
	(11, 41, '2026-02-08', NULL),
	(11, 42, '2026-02-08', NULL),
	(11, 43, '2026-02-08', NULL),
	(11, 44, '2026-02-08', NULL),
	(11, 45, '2026-02-08', NULL),
	(11, 46, '2026-02-08', NULL),
	(11, 47, '2026-02-08', NULL),
	(11, 48, '2026-02-08', NULL),
	(11, 49, '2026-02-08', NULL),
	(11, 50, '2026-02-08', NULL),
	(11, 51, '2026-02-08', NULL),
	(11, 52, '2026-02-08', NULL),
	(11, 53, '2026-02-08', NULL),
	(11, 54, '2026-02-08', NULL),
	(11, 55, '2026-02-08', NULL),
	(11, 56, '2026-02-08', NULL),
	(11, 57, '2026-02-08', NULL),
	(11, 58, '2026-02-08', NULL),
	(11, 59, '2026-02-08', NULL),
	(11, 60, '2026-02-08', NULL),
	(14, 131, '2026-02-08', NULL),
	(14, 132, '2026-02-08', NULL),
	(14, 133, '2026-02-08', NULL),
	(14, 134, '2026-02-08', NULL),
	(14, 135, '2026-02-08', NULL),
	(14, 136, '2026-02-08', NULL),
	(14, 137, '2026-02-08', NULL),
	(14, 138, '2026-02-08', NULL),
	(14, 139, '2026-02-08', NULL),
	(14, 140, '2026-02-08', NULL),
	(14, 141, '2026-02-08', NULL),
	(14, 142, '2026-02-08', NULL),
	(14, 143, '2026-02-08', NULL),
	(14, 144, '2026-02-08', NULL),
	(14, 145, '2026-02-08', NULL),
	(16, 111, '2026-01-08', NULL),
	(16, 112, '2026-01-08', NULL),
	(16, 113, '2026-01-08', NULL),
	(16, 114, '2026-01-08', NULL),
	(16, 115, '2026-01-08', NULL),
	(16, 116, '2026-01-08', NULL),
	(16, 117, '2026-01-08', NULL),
	(16, 118, '2026-01-08', NULL),
	(16, 119, '2026-01-08', NULL),
	(16, 120, '2026-01-08', NULL),
	(16, 121, '2026-01-08', NULL),
	(16, 122, '2026-01-08', NULL),
	(16, 123, '2026-01-08', NULL),
	(16, 124, '2026-01-08', NULL),
	(16, 125, '2026-01-08', NULL),
	(16, 126, '2026-01-08', NULL),
	(16, 127, '2026-01-08', NULL),
	(16, 128, '2026-01-08', NULL),
	(16, 129, '2026-01-08', NULL),
	(16, 130, '2026-01-08', NULL),
	(17, 146, '2025-11-08', NULL),
	(17, 147, '2025-11-08', NULL),
	(17, 148, '2025-11-08', NULL),
	(17, 149, '2025-11-08', NULL),
	(17, 150, '2025-11-08', NULL),
	(17, 151, '2025-11-08', NULL),
	(17, 152, '2025-11-08', NULL),
	(17, 153, '2025-11-08', NULL),
	(17, 154, '2025-11-08', NULL),
	(17, 155, '2025-11-08', NULL),
	(17, 156, '2025-11-08', NULL),
	(17, 157, '2025-11-08', NULL),
	(17, 158, '2025-11-08', NULL),
	(17, 159, '2025-11-08', NULL),
	(17, 160, '2025-11-08', NULL),
	(17, 161, '2025-11-08', NULL),
	(17, 162, '2025-11-08', NULL),
	(17, 163, '2025-11-08', NULL),
	(17, 164, '2025-11-08', NULL),
	(17, 165, '2025-11-08', NULL),
	(20, 166, '2026-02-08', NULL),
	(20, 167, '2026-02-08', NULL),
	(20, 168, '2026-02-08', NULL),
	(20, 169, '2026-02-08', NULL),
	(20, 170, '2026-02-08', NULL),
	(20, 171, '2026-02-08', NULL),
	(20, 172, '2026-02-08', NULL),
	(20, 173, '2026-02-08', NULL),
	(20, 174, '2026-02-08', NULL),
	(20, 175, '2026-02-08', NULL),
	(20, 176, '2026-02-08', NULL),
	(20, 177, '2026-02-08', NULL),
	(20, 178, '2026-02-08', NULL),
	(20, 179, '2026-02-08', NULL),
	(20, 180, '2026-02-08', NULL),
	(20, 181, '2026-02-08', NULL),
	(20, 182, '2026-02-08', NULL),
	(20, 183, '2026-02-08', NULL),
	(20, 184, '2026-02-08', NULL),
	(20, 185, '2026-02-08', NULL),
	(20, 186, '2026-02-08', NULL),
	(20, 187, '2026-02-08', NULL),
	(20, 188, '2026-02-08', NULL),
	(20, 189, '2026-02-08', NULL),
	(20, 190, '2026-02-08', NULL);

-- Data for Name: market_prices; Type: TABLE DATA; Schema: public; Owner: -

-- Data for Name: medical_catalog; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.medical_catalog VALUES
	(2, 'Bovilis IBR Marker Live', 'vaccine', 'Live vaccine for Infectious Bovine Rhinotracheitis (IBR). Intranasal or intramuscular.', 32.50, 0.00, 7, 50, '10 doses', 0),
	(3, 'Bovilis BVD', 'vaccine', 'Inactivated vaccine for Bovine Viral Diarrhoea (BVD). Primary course: 2 doses.', 48.00, 0.00, 7, 30, '50 ml', 0),
	(4, 'Tribovax 10', 'vaccine', 'Clostridial 10-in-1 vaccine (Blackleg, Tetanus, etc). Essential for calves.', 72.50, 0.00, 7, 40, '100 ml', 0),
	(5, 'Leptavoid-H', 'vaccine', 'Protection against Leptospirosis (L. hardjo). Crucial for dairy and breeding herds.', 68.00, 0.00, 7, 20, '50 ml', 0),
	(6, 'Rispoval IBR-Marker Live', 'vaccine', 'Live IBR marker vaccine. Fast onset of immunity.', 34.00, 0.00, 8, 25, '10 doses', 0),
	(7, 'Spirovac', 'vaccine', 'Leptospirosis vaccine. Prevents infection and shedding.', 75.00, 0.00, 8, 20, '50 ml', 0),
	(8, 'Albex 10%', 'medicine', 'Broad spectrum oral drench (Albendazole). Treats worms and adult fluke.', 34.00, 0.00, 9, 60, '1 Liter', 14),
	(9, 'Tribex 10%', 'medicine', 'Triclabendazole drench. Highly effective against acute and chronic liver fluke.', 82.00, 0.00, 9, 15, '2.2 Liter', 56),
	(10, 'Animec Pour-On', 'medicine', 'Ivermectin Pour-On. Treats roundworms, lungworms, and lice. Easy application.', 45.00, 0.00, 9, 40, '2.5 Liter', 15),
	(11, 'Ivomec Super Injection', 'medicine', 'Ivermectin + Clorsulon. Kills external/internal parasites and adult liver fluke.', 145.00, 0.00, 6, 10, '500 ml', 66),
	(12, 'Closamectin Pour-On', 'medicine', 'Combined treatment for fluke and worms. Very popular in wet Irish counties.', 65.00, 0.00, 6, 20, '1 Liter', 28),
	(13, 'Alamycin LA 200', 'medicine', 'Long acting Oxytetracycline. For pneumonia and general infections.', 16.50, 0.00, 6, 30, '100 ml', 21),
	(14, 'Pen & Strep', 'medicine', 'Penicillin + Streptomycin. Daily injection for bacterial infections.', 14.00, 0.00, 6, 40, '100 ml', 18),
	(15, 'Metacam 20mg/ml', 'medicine', 'Anti-inflammatory (NSAID) and painkiller. Critical for mastitis and calving recovery.', 58.00, 0.00, 6, 15, '100 ml', 15),
	(16, 'Hexasol LA', 'medicine', 'Oxytetracycline + Flunixin. Antibiotic with built-in pain relief.', 42.00, 0.00, 6, 10, '100 ml', 21),
	(17, 'Growvite Forte', 'medicine', 'High concentration multi-vitamin and mineral chelated oral drench.', 46.00, 0.00, 9, 50, '1 Liter', 0),
	(18, 'All-Guard Iodine Bolus', 'medicine', 'Slow release bolus (Iodine, Selenium, Cobalt). Lasts 6 months.', 65.00, 0.00, 6, 29, 'Pack 10', 0),
	(19, 'Coseicure Cattle Bolus', 'medicine', 'Copper, Selenium and Cobalt bolus (Glass). Excellent for fertility.', 55.00, 0.00, 6, 25, 'Pack 20', 0),
	(20, 'Calciject 40+3', 'medicine', 'Calcium & Magnesium injection for Milk Fever (Hipocalcemia). Emergency use.', 8.50, 0.00, 9, 20, '400 ml', 0),
	(21, 'Estrumate', 'medicine', 'Prostaglandin. Used to synchronize heat or treat cystic ovaries.', 44.00, 0.00, 7, 10, '20 ml', 1),
	(22, 'Receptal', 'medicine', 'GnRH analogue. Improves conception rates when given at AI.', 32.00, 0.00, 7, 10, '10 ml', 0),
	(23, 'Professional Herd Health Visit', 'service', 'Standard farm call-out for herd health assessment, clinical examinations, and prescription issuance. Professional Irish MVB certification provided.', 185.00, 0.00, 17, 0, 'visit', 0),
	(24, 'Bovine Ultrasound Pregnancy Test', 'service', 'Professional scanning service for pregnancy detection and reproductive health mapping.', 5.50, 0.00, 17, 0, 'per head', 0),
	(25, 'General Vet Visit (Routine)', 'service', 'Visita veterinária padrão para check-up de rebanho, diagnósticos clínicos e prescrição de receitas.', 150.00, 0.00, 17, 0, 'visit', 0),
	(26, 'Emergency Call-out (Night/Weekend)', 'service', 'Atendimento veterinário de emergência fora do horário comercial (Taxa de urgência).', 250.00, 0.00, 17, 0, 'call-out', 0),
	(27, 'Ultrasound Scanning (Pregnancy)', 'service', 'Serviço de ultrassom para detecção de prenhez e mapeamento reprodutivo.', 5.00, 0.00, 17, 0, 'per head', 0),
	(28, 'TB Testing (Annual)', 'service', 'Teste oficial de Tuberculose Bovina (Obrigatório). Serviço realizado por veterinário credenciado.', 4.50, 0.00, 17, 0, 'per head', 0);

-- Data for Name: operational_costs; Type: TABLE DATA; Schema: public; Owner: -

-- Data for Name: sales; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.sales VALUES
	(11, 7, 131, 4, '2026-02-08', 700.00, 6.00, 4200.00, 0.00, 4200.00),
	(12, 7, 131, 4, '2026-02-08', 700.00, 6.00, 4200.00, 0.00, 4200.00),
	(13, 7, 131, 4, '2026-02-08', 700.00, 6.00, 4200.00, 0.00, 4200.00),
	(14, 7, 131, 4, '2026-02-08', 700.00, 6.00, 4200.00, 0.00, 4200.00),
	(15, 7, 131, 4, '2026-02-08', 700.00, 6.00, 4200.00, 0.00, 4200.00),
	(16, 9, 44, 8, '2026-02-08', 613.16, 10.00, 6131.60, 0.00, 6131.60);

-- Data for Name: suppliers; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.suppliers VALUES
	(1, 'Glanbia Agribusiness', 'Patrick Murphy', 'feed', '+353 56 779 6000', 'contact@glanbia.ie', 'Glanbia House, Kilkenny, Co. Kilkenny', 'active'),
	(2, 'Connolly''s Red Mills', 'Gareth Connolly', 'feed', '+353 56 977 5800', 'info@redmills.ie', 'Goresbridge, Co. Kilkenny', 'active'),
	(3, 'Dairygold Co-Op', 'Liam O''Shea', 'feed', '+353 25 24411', 'support@dairygold.ie', 'Mitchelstown, Co. Cork', 'active'),
	(4, 'Lakeland Dairies', 'Sean Eglington', 'feed', '+353 49 436 4200', 'info@lakeland.ie', 'Killeshandra, Co. Cavan', 'active'),
	(5, 'Aurivo Co-op', 'Martin Daly', 'feed', '+353 71 918 6500', 'sales@aurivo.ie', 'Finisklin Business Park, Sligo', 'active'),
	(6, 'Duggan Veterinary Supplies', 'Siobhan Duggan', 'medicine', '+353 504 21599', 'orders@dugganvet.ie', 'Holycross, Thurles, Co. Tipperary', 'active'),
	(7, 'MSD Animal Health Ireland', 'Ciaran Lynch', 'medicine', '+353 1 297 0220', 'vet-support@msd.com', 'Red Oak North, South County Business Park, Dublin 18', 'active'),
	(8, 'Zoetis Ireland', 'Fiona Walsh', 'medicine', '+353 1 256 9800', 'contact@zoetis.ie', 'Cherrywood Business Park, Loughlinstown, Dublin', 'active'),
	(9, 'Chanelle Pharma', 'Michael Burke', 'medicine', '+353 91 841 788', 'sales@chanellegroup.ie', 'Loughrea, Co. Galway', 'active'),
	(10, 'Cork Co-operative Marts', 'Kevin O''Sullivan', 'animals', '+353 21 488 2300', 'info@corkmarts.com', 'Macroom, Co. Cork', 'active'),
	(11, 'Leinster Livestock', 'Eoin Sharkey', 'animals', '+353 86 386 2222', 'trade@leinsterlivestock.ie', 'Granard, Co. Longford', 'active'),
	(12, 'Dovea Genetics', 'Gerard Ryan', 'animals', '+353 504 21755', 'info@dovea.ie', 'Dovea, Thurles, Co. Tipperary', 'active'),
	(13, 'Emerald Isle Beef Producers', 'Niall Brennan', 'animals', '+353 46 924 0200', 'info@emerald-isle.ie', 'Kells, Co. Meath', 'active'),
	(14, 'McHale Farm Machinery', 'Paul McHale', 'other', '+353 94 952 0300', 'sales@mchale.net', 'Ballinrobe, Co. Mayo', 'active'),
	(15, 'FRS Farm Relief Services', 'Peter Byrne', 'other', '+353 505 22100', 'info@frsnetwork.ie', 'Derryvale, Roscrea, Co. Tipperary', 'active'),
	(16, 'Grassland Agro', 'John O''Connell', 'other', '+353 61 301 500', 'advice@grassland.ie', 'Dock Road, Limerick', 'active'),
	(17, 'Elite Herd Health Services', 'Dr. Liam O''Connor (MVB)', 'medicine', '+353 45 871 200', 'clinic@eliteherdhealth.ie', 'Unit 4, Kildare Business Park, Co. Kildare', 'active');

-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.users VALUES
	(1, 5, 'demo', 'Demo Farmer', 'demo@example.com', '', '$2y$10$Piv9ndi1zFldn3rX34EA/ezpsO8y7CON409.w10KrTTHLQszimqEa', '000000');

-- Data for Name: weighing; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.weighing VALUES
	(2, 32, '2025-06-01', 445.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(3, 33, '2025-06-01', 455.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(4, 34, '2025-06-01', 448.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(5, 35, '2025-06-01', 442.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(6, 36, '2025-06-01', 451.30, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(7, 37, '2025-06-01', 446.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(8, 38, '2025-06-01', 453.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(9, 39, '2025-06-01', 449.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(10, 40, '2025-06-01', 444.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(11, 41, '2025-06-01', 452.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(12, 42, '2025-06-01', 447.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(13, 43, '2025-06-01', 443.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(14, 44, '2025-06-01', 456.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(15, 45, '2025-06-01', 450.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(16, 46, '2025-06-01', 445.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(17, 47, '2025-06-01', 454.40, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(18, 48, '2025-06-01', 449.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(19, 49, '2025-06-01', 441.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(20, 50, '2025-06-01', 453.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(21, 51, '2025-06-01', 448.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(22, 52, '2025-06-01', 446.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(23, 53, '2025-06-01', 451.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(24, 54, '2025-06-01', 455.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(25, 55, '2025-06-01', 444.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(26, 56, '2025-06-01', 452.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(27, 57, '2025-06-01', 447.30, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(28, 58, '2025-06-01', 443.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(29, 59, '2025-06-01', 457.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(30, 60, '2025-06-01', 449.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(31, 61, '2025-06-01', 600.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(32, 62, '2025-06-01', 595.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(33, 63, '2025-06-01', 605.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(34, 64, '2025-06-01', 598.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(35, 65, '2025-06-01', 592.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(36, 66, '2025-06-01', 601.30, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(37, 67, '2025-06-01', 596.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(38, 68, '2025-06-01', 603.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(39, 69, '2025-06-01', 599.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(40, 70, '2025-06-01', 594.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(41, 71, '2025-06-01', 602.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(42, 72, '2025-06-01', 597.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(43, 73, '2025-06-01', 593.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(44, 74, '2025-06-01', 606.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(45, 75, '2025-06-01', 600.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(46, 76, '2025-06-01', 595.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(47, 77, '2025-06-01', 604.40, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(48, 78, '2025-06-01', 599.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(49, 79, '2025-06-01', 591.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(50, 80, '2025-06-01', 603.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(51, 81, '2025-06-01', 598.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(52, 82, '2025-06-01', 596.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(53, 83, '2025-06-01', 601.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(54, 84, '2025-06-01', 605.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(55, 85, '2025-06-01', 594.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(56, 86, '2025-06-01', 602.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(57, 87, '2025-06-01', 597.30, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(58, 88, '2025-06-01', 593.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(59, 89, '2025-06-01', 607.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(60, 90, '2025-06-01', 599.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(61, 91, '2025-06-01', 250.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(62, 92, '2025-06-01', 245.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(63, 93, '2025-06-01', 255.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(64, 94, '2025-06-01', 248.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(65, 95, '2025-06-01', 242.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(66, 96, '2025-06-01', 251.30, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(67, 97, '2025-06-01', 246.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(68, 98, '2025-06-01', 253.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(69, 99, '2025-06-01', 249.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(70, 100, '2025-06-01', 244.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(71, 101, '2025-06-01', 252.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(72, 102, '2025-06-01', 247.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(73, 103, '2025-06-01', 243.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(74, 104, '2025-06-01', 256.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(75, 105, '2025-06-01', 250.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(76, 106, '2025-06-01', 245.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(77, 107, '2025-06-01', 254.40, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(78, 108, '2025-06-01', 249.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(79, 109, '2025-06-01', 241.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(80, 110, '2025-06-01', 253.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(81, 111, '2025-06-01', 120.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(82, 112, '2025-06-01', 115.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(83, 113, '2025-06-01', 125.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(84, 114, '2025-06-01', 118.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(85, 115, '2025-06-01', 112.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(86, 116, '2025-06-01', 121.30, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(87, 117, '2025-06-01', 116.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(88, 118, '2025-06-01', 123.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(89, 119, '2025-06-01', 119.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(90, 120, '2025-06-01', 114.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(91, 121, '2025-06-01', 122.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(92, 122, '2025-06-01', 117.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(93, 123, '2025-06-01', 113.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(94, 124, '2025-06-01', 126.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(95, 125, '2025-06-01', 120.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(96, 126, '2025-06-01', 115.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(97, 127, '2025-06-01', 124.40, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(98, 128, '2025-06-01', 119.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(99, 129, '2025-06-01', 111.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(100, 130, '2025-06-01', 123.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(101, 146, '2025-06-01', 480.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(102, 147, '2025-06-01', 475.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(103, 148, '2025-06-01', 485.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(104, 149, '2025-06-01', 478.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(105, 150, '2025-06-01', 472.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(106, 151, '2025-06-01', 481.30, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(107, 152, '2025-06-01', 476.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(108, 153, '2025-06-01', 483.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(109, 154, '2025-06-01', 479.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(110, 155, '2025-06-01', 474.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(111, 156, '2025-06-01', 482.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(112, 157, '2025-06-01', 477.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(113, 158, '2025-06-01', 473.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(114, 159, '2025-06-01', 486.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(115, 160, '2025-06-01', 480.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(116, 161, '2025-06-01', 475.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(117, 162, '2025-06-01', 484.40, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(118, 163, '2025-06-01', 479.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(119, 164, '2025-06-01', 471.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(120, 165, '2025-06-01', 483.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(121, 166, '2025-06-01', 380.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(122, 167, '2025-06-01', 375.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(123, 168, '2025-06-01', 385.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(124, 169, '2025-06-01', 378.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(125, 170, '2025-06-01', 372.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(126, 171, '2025-06-01', 381.30, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(127, 172, '2025-06-01', 376.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(128, 173, '2025-06-01', 383.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(129, 174, '2025-06-01', 379.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(130, 175, '2025-06-01', 374.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(131, 176, '2025-06-01', 382.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(132, 177, '2025-06-01', 377.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(133, 178, '2025-06-01', 373.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(134, 179, '2025-06-01', 386.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(135, 180, '2025-06-01', 380.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(136, 181, '2025-06-01', 375.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(137, 182, '2025-06-01', 384.40, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(138, 183, '2025-06-01', 379.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(139, 184, '2025-06-01', 371.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(140, 185, '2025-06-01', 383.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(141, 186, '2025-06-01', 378.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(142, 187, '2025-06-01', 376.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(143, 188, '2025-06-01', 381.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(144, 189, '2025-06-01', 385.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(145, 190, '2025-06-01', 374.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(146, 131, '2025-06-01', 400.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(147, 132, '2025-06-01', 395.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(148, 133, '2025-06-01', 405.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(149, 134, '2025-06-01', 398.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(150, 135, '2025-06-01', 392.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(151, 136, '2025-06-01', 401.30, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(152, 137, '2025-06-01', 396.70, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(153, 138, '2025-06-01', 403.90, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(154, 139, '2025-06-01', 399.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(155, 140, '2025-06-01', 394.50, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(156, 141, '2025-06-01', 402.20, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(157, 142, '2025-06-01', 397.80, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(158, 143, '2025-06-01', 393.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(159, 144, '2025-06-01', 406.10, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(160, 145, '2025-06-01', 400.00, NULL, 'import', '1_1770557227.txt', NULL, '2026-02-08 13:27:16', 1),
	(162, 32, '2025-07-01', 478.96, 1.13, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(163, 33, '2025-07-01', 480.67, 0.86, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(164, 34, '2025-07-01', 482.03, 1.11, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(165, 35, '2025-07-01', 477.59, 1.18, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(166, 36, '2025-07-01', 481.01, 0.99, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(167, 37, '2025-07-01', 480.14, 1.12, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(168, 38, '2025-07-01', 478.66, 0.83, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(169, 39, '2025-07-01', 479.42, 1.01, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(170, 40, '2025-07-01', 482.03, 1.25, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(171, 41, '2025-07-01', 481.98, 0.99, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(172, 42, '2025-07-01', 478.67, 1.03, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(173, 43, '2025-07-01', 482.46, 1.32, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(174, 44, '2025-07-01', 480.56, 0.82, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(175, 45, '2025-07-01', 480.83, 1.03, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(176, 46, '2025-07-01', 482.44, 1.22, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(177, 47, '2025-07-01', 480.93, 0.88, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(178, 48, '2025-07-01', 478.53, 0.96, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(179, 49, '2025-07-01', 481.39, 1.33, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(180, 50, '2025-07-01', 481.29, 0.94, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:49', 2),
	(181, 51, '2025-07-01', 481.36, 1.11, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(182, 52, '2025-07-01', 480.17, 1.14, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(183, 53, '2025-07-01', 478.65, 0.90, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(184, 54, '2025-07-01', 479.30, 0.79, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(185, 55, '2025-07-01', 481.58, 1.25, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(186, 56, '2025-07-01', 477.73, 0.83, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(187, 57, '2025-07-01', 482.20, 1.16, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(188, 58, '2025-07-01', 481.46, 1.27, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(189, 59, '2025-07-01', 479.27, 0.74, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(190, 60, '2025-07-01', 479.82, 1.02, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(191, 61, '2025-07-01', 641.38, 1.36, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(192, 62, '2025-07-01', 638.05, 1.43, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(193, 63, '2025-07-01', 639.45, 1.15, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(194, 64, '2025-07-01', 637.31, 1.28, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(195, 65, '2025-07-01', 639.93, 1.59, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(196, 66, '2025-07-01', 636.64, 1.18, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(197, 67, '2025-07-01', 641.04, 1.48, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(198, 68, '2025-07-01', 637.99, 1.14, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(199, 69, '2025-07-01', 639.17, 1.34, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(200, 70, '2025-07-01', 638.80, 1.48, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(201, 71, '2025-07-01', 641.03, 1.29, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(202, 72, '2025-07-01', 639.47, 1.39, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2);
INSERT INTO public.weighing VALUES
	(203, 73, '2025-07-01', 636.77, 1.46, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(204, 74, '2025-07-01', 641.46, 1.18, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(205, 75, '2025-07-01', 639.14, 1.31, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(206, 76, '2025-07-01', 641.35, 1.52, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(207, 77, '2025-07-01', 638.84, 1.15, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(208, 78, '2025-07-01', 640.52, 1.36, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(209, 79, '2025-07-01', 639.37, 1.60, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(210, 80, '2025-07-01', 641.04, 1.27, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(211, 81, '2025-07-01', 637.59, 1.31, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(212, 82, '2025-07-01', 640.31, 1.48, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(213, 83, '2025-07-01', 636.82, 1.17, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(214, 84, '2025-07-01', 638.11, 1.09, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(215, 85, '2025-07-01', 638.10, 1.47, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(216, 86, '2025-07-01', 639.65, 1.23, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(217, 87, '2025-07-01', 636.57, 1.31, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(218, 88, '2025-07-01', 636.73, 1.44, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(219, 89, '2025-07-01', 641.12, 1.14, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(220, 90, '2025-07-01', 638.94, 1.33, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(221, 91, '2025-07-01', 278.57, 0.94, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(222, 92, '2025-07-01', 277.04, 1.06, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(223, 93, '2025-07-01', 277.87, 0.76, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(224, 94, '2025-07-01', 275.60, 0.89, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(225, 95, '2025-07-01', 278.71, 1.22, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(226, 96, '2025-07-01', 275.15, 0.80, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(227, 97, '2025-07-01', 279.16, 1.08, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(228, 98, '2025-07-01', 277.74, 0.80, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(229, 99, '2025-07-01', 275.03, 0.87, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(230, 100, '2025-07-01', 278.62, 1.14, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(231, 101, '2025-07-01', 278.41, 0.87, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(232, 102, '2025-07-01', 278.64, 1.03, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(233, 103, '2025-07-01', 275.99, 1.10, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(234, 104, '2025-07-01', 279.40, 0.78, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(235, 105, '2025-07-01', 275.73, 0.86, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(236, 106, '2025-07-01', 275.85, 1.00, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(237, 107, '2025-07-01', 277.66, 0.78, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(238, 108, '2025-07-01', 277.90, 0.94, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(239, 109, '2025-07-01', 277.30, 1.19, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(240, 110, '2025-07-01', 275.76, 0.76, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(241, 111, '2025-07-01', 141.94, 0.72, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(242, 112, '2025-07-01', 145.02, 0.99, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(243, 113, '2025-07-01', 145.71, 0.69, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(244, 114, '2025-07-01', 141.60, 0.76, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(245, 115, '2025-07-01', 144.97, 1.10, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(246, 116, '2025-07-01', 143.63, 0.74, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(247, 117, '2025-07-01', 142.02, 0.84, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(248, 118, '2025-07-01', 146.33, 0.75, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(249, 119, '2025-07-01', 142.28, 0.78, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(250, 120, '2025-07-01', 144.66, 1.01, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(251, 121, '2025-07-01', 143.10, 0.70, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(252, 122, '2025-07-01', 143.44, 0.86, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(253, 123, '2025-07-01', 142.94, 1.00, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(254, 124, '2025-07-01', 146.20, 0.67, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(255, 125, '2025-07-01', 144.39, 0.81, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(256, 126, '2025-07-01', 144.11, 0.94, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(257, 127, '2025-07-01', 141.78, 0.58, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(258, 128, '2025-07-01', 143.69, 0.80, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(259, 129, '2025-07-01', 141.87, 1.01, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(260, 130, '2025-07-01', 144.84, 0.73, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(261, 146, '2025-07-01', 512.75, 1.08, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(262, 147, '2025-07-01', 513.93, 1.29, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(263, 148, '2025-07-01', 510.89, 0.86, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(264, 149, '2025-07-01', 514.04, 1.18, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(265, 150, '2025-07-01', 512.96, 1.36, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(266, 151, '2025-07-01', 511.00, 0.99, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(267, 152, '2025-07-01', 511.19, 1.15, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(268, 153, '2025-07-01', 511.80, 0.93, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(269, 154, '2025-07-01', 511.67, 1.09, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(270, 155, '2025-07-01', 513.71, 1.31, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(271, 156, '2025-07-01', 510.71, 0.95, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(272, 157, '2025-07-01', 514.13, 1.21, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(273, 158, '2025-07-01', 511.05, 1.27, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(274, 159, '2025-07-01', 514.74, 0.96, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(275, 160, '2025-07-01', 512.00, 1.07, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(276, 161, '2025-07-01', 511.50, 1.19, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(277, 162, '2025-07-01', 511.63, 0.91, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(278, 163, '2025-07-01', 512.82, 1.10, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(279, 164, '2025-07-01', 512.29, 1.36, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(280, 165, '2025-07-01', 511.30, 0.94, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(281, 166, '2025-07-01', 405.31, 0.83, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(282, 167, '2025-07-01', 404.87, 0.99, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(283, 168, '2025-07-01', 403.11, 0.60, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(284, 169, '2025-07-01', 406.18, 0.91, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(285, 170, '2025-07-01', 404.20, 1.07, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(286, 171, '2025-07-01', 407.09, 0.86, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(287, 172, '2025-07-01', 405.82, 0.97, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(288, 173, '2025-07-01', 405.72, 0.73, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(289, 174, '2025-07-01', 403.26, 0.81, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(290, 175, '2025-07-01', 404.63, 1.00, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(291, 176, '2025-07-01', 404.41, 0.74, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(292, 177, '2025-07-01', 404.95, 0.91, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(293, 178, '2025-07-01', 406.23, 1.11, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(294, 179, '2025-07-01', 403.02, 0.56, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(295, 180, '2025-07-01', 407.39, 0.91, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(296, 181, '2025-07-01', 403.97, 0.94, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(297, 182, '2025-07-01', 403.86, 0.65, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(298, 183, '2025-07-01', 407.23, 0.92, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(299, 184, '2025-07-01', 405.68, 1.14, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(300, 185, '2025-07-01', 406.52, 0.78, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(301, 186, '2025-07-01', 405.10, 0.90, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(302, 187, '2025-07-01', 405.83, 0.99, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(303, 188, '2025-07-01', 406.81, 0.83, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(304, 189, '2025-07-01', 407.64, 0.74, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(305, 190, '2025-07-01', 405.70, 1.06, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(306, 131, '2025-07-01', 419.58, 0.64, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(307, 132, '2025-07-01', 416.43, 0.71, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(308, 133, '2025-07-01', 420.13, 0.50, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(309, 134, '2025-07-01', 419.83, 0.70, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(310, 135, '2025-07-01', 419.54, 0.92, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(311, 136, '2025-07-01', 416.38, 0.50, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(312, 137, '2025-07-01', 415.51, 0.63, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(313, 138, '2025-07-01', 417.04, 0.44, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(314, 139, '2025-07-01', 418.18, 0.64, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(315, 140, '2025-07-01', 418.11, 0.79, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(316, 141, '2025-07-01', 417.93, 0.52, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(317, 142, '2025-07-01', 419.91, 0.74, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(318, 143, '2025-07-01', 419.55, 0.89, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(319, 144, '2025-07-01', 416.80, 0.36, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(320, 145, '2025-07-01', 419.27, 0.64, 'import', '2_1770557262.txt', NULL, '2026-02-08 13:27:50', 2),
	(322, 32, '2025-09-01', 536.80, 0.93, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(323, 33, '2025-09-01', 538.20, 0.93, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(324, 34, '2025-09-01', 541.50, 0.96, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(325, 35, '2025-09-01', 495.00, 0.28, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(326, 36, '2025-09-01', 540.10, 0.95, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(327, 37, '2025-09-01', 537.90, 0.93, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(328, 38, '2025-09-01', 535.40, 0.92, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(329, 39, '2025-09-01', 538.00, 0.95, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(330, 40, '2025-09-01', 540.80, 0.95, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(331, 41, '2025-09-01', 541.20, 0.96, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(332, 42, '2025-09-01', 536.50, 0.93, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(333, 43, '2025-09-01', 542.10, 0.96, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(334, 44, '2025-09-01', 539.00, 0.94, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(335, 45, '2025-09-01', 540.40, 0.96, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(336, 46, '2025-09-01', 542.80, 0.97, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(337, 47, '2025-09-01', 539.50, 0.95, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(338, 48, '2025-09-01', 537.10, 0.95, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(339, 49, '2025-09-01', 540.90, 0.96, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(340, 50, '2025-09-01', 539.80, 0.94, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(341, 51, '2025-09-01', 540.00, 0.95, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(342, 52, '2025-09-01', 538.40, 0.94, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(343, 53, '2025-09-01', 536.90, 0.94, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(344, 54, '2025-09-01', 537.50, 0.94, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(345, 55, '2025-09-01', 541.00, 0.96, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(346, 56, '2025-09-01', 536.20, 0.94, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(347, 57, '2025-09-01', 542.50, 0.97, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(348, 58, '2025-09-01', 540.70, 0.96, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(349, 59, '2025-09-01', 537.80, 0.94, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(350, 60, '2025-09-01', 538.60, 0.95, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(351, 61, '2025-09-01', 716.50, 1.21, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(352, 62, '2025-09-01', 714.20, 1.23, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(353, 63, '2025-09-01', 715.90, 1.23, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(354, 64, '2025-09-01', 711.40, 1.20, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(355, 65, '2025-09-01', 717.10, 1.25, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(356, 66, '2025-09-01', 713.00, 1.23, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(357, 67, '2025-09-01', 718.50, 1.25, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(358, 68, '2025-09-01', 715.30, 1.25, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(359, 69, '2025-09-01', 716.00, 1.24, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(360, 70, '2025-09-01', 715.50, 1.24, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(361, 71, '2025-09-01', 718.10, 1.24, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(362, 72, '2025-09-01', 716.40, 1.24, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(363, 73, '2025-09-01', 711.90, 1.21, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(364, 74, '2025-09-01', 719.00, 1.25, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(365, 75, '2025-09-01', 716.20, 1.24, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(366, 76, '2025-09-01', 718.80, 1.25, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(367, 77, '2025-09-01', 714.50, 1.22, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(368, 78, '2025-09-01', 717.20, 1.24, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(369, 79, '2025-09-01', 715.90, 1.23, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(370, 80, '2025-09-01', 718.40, 1.25, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(371, 81, '2025-09-01', 655.00, 0.28, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(372, 82, '2025-09-01', 717.50, 1.25, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(373, 83, '2025-09-01', 712.00, 1.21, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(374, 84, '2025-09-01', 715.20, 1.24, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(375, 85, '2025-09-01', 714.80, 1.24, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(376, 86, '2025-09-01', 716.50, 1.24, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(377, 87, '2025-09-01', 711.80, 1.21, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(378, 88, '2025-09-01', 712.20, 1.22, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(379, 89, '2025-09-01', 718.00, 1.24, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(380, 90, '2025-09-01', 716.10, 1.25, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(381, 91, '2025-09-01', 329.50, 0.82, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(382, 92, '2025-09-01', 327.20, 0.81, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(383, 93, '2025-09-01', 328.80, 0.82, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(384, 94, '2025-09-01', 325.50, 0.81, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(385, 95, '2025-09-01', 330.00, 0.83, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(386, 96, '2025-09-01', 326.10, 0.82, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(387, 97, '2025-09-01', 331.50, 0.84, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(388, 98, '2025-09-01', 328.90, 0.83, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(389, 99, '2025-09-01', 325.80, 0.82, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(390, 100, '2025-09-01', 330.20, 0.83, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(391, 101, '2025-09-01', 329.40, 0.82, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(392, 102, '2025-09-01', 330.10, 0.83, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(393, 103, '2025-09-01', 326.50, 0.82, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(394, 104, '2025-09-01', 331.80, 0.85, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(395, 105, '2025-09-01', 326.90, 0.83, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(396, 106, '2025-09-01', 327.00, 0.83, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(397, 107, '2025-09-01', 329.20, 0.83, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(398, 108, '2025-09-01', 330.50, 0.85, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(399, 109, '2025-09-01', 328.00, 0.82, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(400, 110, '2025-09-01', 326.60, 0.82, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(401, 111, '2025-09-01', 170.50, 0.46, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(402, 112, '2025-09-01', 171.20, 0.42, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(403, 113, '2025-09-01', 168.10, 0.36, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3);
INSERT INTO public.weighing VALUES
	(404, 114, '2025-09-01', 169.50, 0.45, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(405, 115, '2025-09-01', 172.00, 0.44, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(406, 116, '2025-09-01', 165.80, 0.36, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(407, 117, '2025-09-01', 167.20, 0.41, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(408, 118, '2025-09-01', 174.50, 0.45, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(409, 119, '2025-09-01', 169.00, 0.43, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(410, 120, '2025-09-01', 171.80, 0.44, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(411, 121, '2025-09-01', 170.20, 0.44, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(412, 122, '2025-09-01', 171.00, 0.45, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(413, 123, '2025-09-01', 169.50, 0.43, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(414, 124, '2025-09-01', 174.00, 0.45, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(415, 125, '2025-09-01', 172.20, 0.45, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(416, 126, '2025-09-01', 166.50, 0.36, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(417, 127, '2025-09-01', 169.10, 0.44, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(418, 128, '2025-09-01', 170.90, 0.44, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(419, 129, '2025-09-01', 165.80, 0.39, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(420, 130, '2025-09-01', 172.50, 0.45, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(421, 146, '2025-09-01', 566.20, 0.86, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(422, 147, '2025-09-01', 568.50, 0.88, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(423, 148, '2025-09-01', 564.80, 0.87, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(424, 149, '2025-09-01', 569.00, 0.89, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(425, 150, '2025-09-01', 567.20, 0.88, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(426, 151, '2025-09-01', 529.00, 0.29, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(427, 152, '2025-09-01', 565.50, 0.88, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(428, 153, '2025-09-01', 566.90, 0.89, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(429, 154, '2025-09-01', 566.00, 0.88, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(430, 155, '2025-09-01', 568.80, 0.89, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(431, 156, '2025-09-01', 564.50, 0.87, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(432, 157, '2025-09-01', 569.20, 0.89, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(433, 158, '2025-09-01', 565.10, 0.87, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(434, 159, '2025-09-01', 570.50, 0.90, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(435, 160, '2025-09-01', 566.80, 0.88, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(436, 161, '2025-09-01', 565.90, 0.88, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(437, 162, '2025-09-01', 566.10, 0.88, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(438, 163, '2025-09-01', 567.50, 0.88, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(439, 164, '2025-09-01', 566.70, 0.88, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(440, 165, '2025-09-01', 565.20, 0.87, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(441, 166, '2025-09-01', 451.50, 0.75, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(442, 167, '2025-09-01', 450.80, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(443, 168, '2025-09-01', 449.10, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(444, 169, '2025-09-01', 452.50, 0.75, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(445, 170, '2025-09-01', 450.00, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(446, 171, '2025-09-01', 453.20, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(447, 172, '2025-09-01', 451.80, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(448, 173, '2025-09-01', 452.00, 0.75, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(449, 174, '2025-09-01', 449.50, 0.75, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(450, 175, '2025-09-01', 450.90, 0.75, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(451, 176, '2025-09-01', 450.60, 0.75, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(452, 177, '2025-09-01', 451.20, 0.75, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(453, 178, '2025-09-01', 452.80, 0.75, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(454, 179, '2025-09-01', 449.00, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(455, 180, '2025-09-01', 453.50, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(456, 181, '2025-09-01', 450.10, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(457, 182, '2025-09-01', 449.90, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(458, 183, '2025-09-01', 453.10, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(459, 184, '2025-09-01', 451.50, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(460, 185, '2025-09-01', 452.80, 0.75, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(461, 186, '2025-09-01', 451.00, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(462, 187, '2025-09-01', 451.80, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(463, 188, '2025-09-01', 452.80, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(464, 189, '2025-09-01', 453.60, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(465, 190, '2025-09-01', 451.70, 0.74, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(466, 131, '2025-09-01', 431.50, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(467, 132, '2025-09-01', 428.40, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(468, 133, '2025-09-01', 432.10, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(469, 134, '2025-09-01', 431.80, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(470, 135, '2025-09-01', 431.50, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(471, 136, '2025-09-01', 428.30, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(472, 137, '2025-09-01', 427.50, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(473, 138, '2025-09-01', 429.00, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(474, 139, '2025-09-01', 430.10, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(475, 140, '2025-09-01', 430.10, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(476, 141, '2025-09-01', 429.90, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(477, 142, '2025-09-01', 431.90, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(478, 143, '2025-09-01', 431.50, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(479, 144, '2025-09-01', 428.80, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(480, 145, '2025-09-01', 431.20, 0.19, 'import', '3_1770557289.txt', NULL, '2026-02-08 13:28:17', 3),
	(482, 32, '2025-10-01', 557.35, 0.69, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(483, 33, '2025-10-01', 566.26, 0.94, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(484, 34, '2025-10-01', 550.90, 0.31, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(485, 35, '2025-10-01', 563.03, 2.27, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(486, 36, '2025-10-01', 554.90, 0.49, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(487, 37, '2025-10-01', 564.16, 0.88, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(488, 38, '2025-10-01', 561.92, 0.88, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(489, 39, '2025-10-01', 551.46, 0.45, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(490, 40, '2025-10-01', 560.20, 0.65, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(491, 41, '2025-10-01', 558.32, 0.57, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(492, 42, '2025-10-01', 561.50, 0.83, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(493, 43, '2025-10-01', 565.03, 0.76, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(494, 44, '2025-10-01', 560.69, 0.72, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(495, 45, '2025-10-01', 554.87, 0.48, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(496, 46, '2025-10-01', 563.27, 0.68, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(497, 47, '2025-10-01', 557.32, 0.59, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(498, 48, '2025-10-01', 558.81, 0.72, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(499, 49, '2025-10-01', 555.00, 0.47, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(500, 50, '2025-10-01', 563.18, 0.78, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(501, 51, '2025-10-01', 558.89, 0.63, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(502, 52, '2025-10-01', 551.90, 0.45, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(503, 53, '2025-10-01', 561.45, 0.82, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(504, 54, '2025-10-01', 565.93, 0.95, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(505, 55, '2025-10-01', 574.95, 1.13, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(506, 56, '2025-10-01', 558.83, 0.75, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(507, 57, '2025-10-01', 557.18, 0.49, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(508, 58, '2025-10-01', 559.66, 0.63, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(509, 59, '2025-10-01', 553.71, 0.53, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(510, 60, '2025-10-01', 557.83, 0.64, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(511, 61, '2025-10-01', 745.29, 0.96, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(512, 62, '2025-10-01', 750.56, 1.21, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(513, 63, '2025-10-01', 748.69, 1.09, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(514, 64, '2025-10-01', 745.30, 1.13, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(515, 65, '2025-10-01', 754.65, 1.25, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(516, 66, '2025-10-01', 751.22, 1.27, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(517, 67, '2025-10-01', 756.13, 1.25, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(518, 68, '2025-10-01', 742.52, 0.91, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(519, 69, '2025-10-01', 749.42, 1.11, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(520, 70, '2025-10-01', 750.42, 1.16, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(521, 71, '2025-10-01', 749.46, 1.05, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(522, 72, '2025-10-01', 748.93, 1.08, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(523, 73, '2025-10-01', 757.46, 1.52, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(524, 74, '2025-10-01', 759.86, 1.36, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(525, 75, '2025-10-01', 753.91, 1.26, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(526, 76, '2025-10-01', 751.19, 1.08, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(527, 77, '2025-10-01', 747.04, 1.09, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(528, 78, '2025-10-01', 751.65, 1.15, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(529, 79, '2025-10-01', 743.47, 0.92, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(530, 80, '2025-10-01', 750.81, 1.08, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(531, 81, '2025-10-01', 750.28, 3.18, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(532, 82, '2025-10-01', 753.92, 1.21, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(533, 83, '2025-10-01', 746.53, 1.15, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(534, 84, '2025-10-01', 755.10, 1.33, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(535, 85, '2025-10-01', 755.99, 1.37, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(536, 86, '2025-10-01', 747.95, 1.05, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(537, 87, '2025-10-01', 749.12, 1.24, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(538, 88, '2025-10-01', 755.82, 1.45, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(539, 89, '2025-10-01', 748.90, 1.03, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(540, 90, '2025-10-01', 746.15, 1.00, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(541, 91, '2025-10-01', 350.32, 0.69, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(542, 92, '2025-10-01', 352.26, 0.84, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(543, 93, '2025-10-01', 345.04, 0.54, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(544, 94, '2025-10-01', 350.17, 0.82, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(545, 95, '2025-10-01', 352.56, 0.75, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(546, 96, '2025-10-01', 349.74, 0.79, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(547, 97, '2025-10-01', 352.33, 0.69, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(548, 98, '2025-10-01', 350.57, 0.72, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(549, 99, '2025-10-01', 348.50, 0.76, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(550, 100, '2025-10-01', 357.72, 0.92, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(551, 101, '2025-10-01', 350.04, 0.69, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(552, 102, '2025-10-01', 348.16, 0.60, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(553, 103, '2025-10-01', 352.35, 0.86, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(554, 104, '2025-10-01', 352.00, 0.67, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(555, 105, '2025-10-01', 344.45, 0.59, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(556, 106, '2025-10-01', 355.98, 0.97, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(557, 107, '2025-10-01', 353.57, 0.81, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(558, 108, '2025-10-01', 352.90, 0.75, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(559, 109, '2025-10-01', 347.42, 0.65, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(560, 110, '2025-10-01', 350.73, 0.80, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(561, 111, '2025-10-01', 177.08, 0.22, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(562, 112, '2025-10-01', 180.43, 0.31, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(563, 113, '2025-10-01', 185.81, 0.59, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(564, 114, '2025-10-01', 178.99, 0.32, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(565, 115, '2025-10-01', 182.64, 0.36, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(566, 116, '2025-10-01', 187.73, 0.73, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(567, 117, '2025-10-01', 182.79, 0.52, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(568, 118, '2025-10-01', 182.15, 0.26, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(569, 119, '2025-10-01', 183.52, 0.48, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(570, 120, '2025-10-01', 180.43, 0.29, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(571, 121, '2025-10-01', 168.80, -0.05, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(572, 122, '2025-10-01', 168.80, -0.07, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(573, 123, '2025-10-01', 188.30, 0.63, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(574, 124, '2025-10-01', 182.07, 0.27, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(575, 125, '2025-10-01', 176.33, 0.14, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(576, 126, '2025-10-01', 182.71, 0.54, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(577, 127, '2025-10-01', 172.53, 0.11, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(578, 128, '2025-10-01', 189.52, 0.62, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(579, 129, '2025-10-01', 177.09, 0.38, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(580, 130, '2025-10-01', 187.69, 0.51, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(581, 146, '2025-10-01', 577.48, 0.38, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(582, 147, '2025-10-01', 580.91, 0.41, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(583, 148, '2025-10-01', 577.64, 0.43, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(584, 149, '2025-10-01', 582.91, 0.46, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(585, 150, '2025-10-01', 577.88, 0.36, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(586, 151, '2025-10-01', 568.97, 1.33, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(587, 152, '2025-10-01', 586.80, 0.71, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(588, 153, '2025-10-01', 574.83, 0.26, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(589, 154, '2025-10-01', 572.55, 0.22, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(590, 155, '2025-10-01', 570.64, 0.06, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(591, 156, '2025-10-01', 581.92, 0.58, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(592, 157, '2025-10-01', 571.31, 0.07, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(593, 158, '2025-10-01', 568.55, 0.12, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(594, 159, '2025-10-01', 580.86, 0.35, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(595, 160, '2025-10-01', 587.75, 0.70, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(596, 161, '2025-10-01', 572.17, 0.21, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(597, 162, '2025-10-01', 573.67, 0.25, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(598, 163, '2025-10-01', 582.81, 0.51, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(599, 164, '2025-10-01', 576.15, 0.32, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(600, 165, '2025-10-01', 572.05, 0.23, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(601, 166, '2025-10-01', 467.63, 0.54, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(602, 167, '2025-10-01', 467.06, 0.54, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(603, 168, '2025-10-01', 471.22, 0.74, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(604, 169, '2025-10-01', 463.97, 0.38, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4);
INSERT INTO public.weighing VALUES
	(605, 170, '2025-10-01', 460.85, 0.36, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(606, 171, '2025-10-01', 469.04, 0.53, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(607, 172, '2025-10-01', 465.42, 0.45, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(608, 173, '2025-10-01', 465.63, 0.45, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(609, 174, '2025-10-01', 463.27, 0.46, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(610, 175, '2025-10-01', 467.95, 0.57, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(611, 176, '2025-10-01', 461.07, 0.35, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(612, 177, '2025-10-01', 462.84, 0.39, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(613, 178, '2025-10-01', 462.03, 0.31, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(614, 179, '2025-10-01', 466.73, 0.59, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(615, 180, '2025-10-01', 472.07, 0.62, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(616, 181, '2025-10-01', 471.11, 0.70, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(617, 182, '2025-10-01', 467.92, 0.60, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(618, 183, '2025-10-01', 461.19, 0.27, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(619, 184, '2025-10-01', 469.46, 0.60, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(620, 185, '2025-10-01', 463.18, 0.35, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(621, 186, '2025-10-01', 463.11, 0.40, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(622, 187, '2025-10-01', 467.52, 0.52, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(623, 188, '2025-10-01', 464.80, 0.40, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(624, 189, '2025-10-01', 467.41, 0.46, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(625, 190, '2025-10-01', 461.47, 0.33, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(626, 131, '2025-10-01', 446.64, 0.51, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(627, 132, '2025-10-01', 430.54, 0.07, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(628, 133, '2025-10-01', 426.50, -0.19, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(629, 134, '2025-10-01', 435.09, 0.11, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(630, 135, '2025-10-01', 433.22, 0.06, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(631, 136, '2025-10-01', 426.50, -0.06, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(632, 137, '2025-10-01', 425.29, -0.07, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(633, 138, '2025-10-01', 440.86, 0.40, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(634, 139, '2025-10-01', 426.50, -0.12, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(635, 140, '2025-10-01', 431.96, 0.06, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(636, 141, '2025-10-01', 418.50, -0.38, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(637, 142, '2025-10-01', 437.32, 0.18, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(638, 143, '2025-10-01', 436.54, 0.17, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(639, 144, '2025-10-01', 432.24, 0.12, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(640, 145, '2025-10-01', 414.68, -0.55, 'import', '4_1770557316.txt', NULL, '2026-02-08 13:28:42', 4),
	(642, 32, '2025-10-01', 557.35, 0.69, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(643, 33, '2025-10-01', 566.26, 0.94, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(644, 34, '2025-10-01', 550.90, 0.31, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(645, 35, '2025-10-01', 563.03, 2.27, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(646, 36, '2025-10-01', 554.90, 0.49, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(647, 37, '2025-10-01', 564.16, 0.88, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(648, 38, '2025-10-01', 561.92, 0.88, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(649, 39, '2025-10-01', 551.46, 0.45, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(650, 40, '2025-10-01', 560.20, 0.65, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(651, 41, '2025-10-01', 558.32, 0.57, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(652, 42, '2025-10-01', 561.50, 0.83, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(653, 43, '2025-10-01', 565.03, 0.76, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(654, 44, '2025-10-01', 560.69, 0.72, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(655, 45, '2025-10-01', 554.87, 0.48, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(656, 46, '2025-10-01', 563.27, 0.68, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(657, 47, '2025-10-01', 557.32, 0.59, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(658, 48, '2025-10-01', 558.81, 0.72, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(659, 49, '2025-10-01', 555.00, 0.47, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(660, 50, '2025-10-01', 563.18, 0.78, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(661, 51, '2025-10-01', 558.89, 0.63, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(662, 52, '2025-10-01', 551.90, 0.45, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(663, 53, '2025-10-01', 561.45, 0.82, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(664, 54, '2025-10-01', 565.93, 0.95, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(665, 55, '2025-10-01', 574.95, 1.13, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(666, 56, '2025-10-01', 558.83, 0.75, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(667, 57, '2025-10-01', 557.18, 0.49, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(668, 58, '2025-10-01', 559.66, 0.63, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(669, 59, '2025-10-01', 553.71, 0.53, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(670, 60, '2025-10-01', 557.83, 0.64, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(671, 61, '2025-10-01', 745.29, 0.96, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(672, 62, '2025-10-01', 750.56, 1.21, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(673, 63, '2025-10-01', 748.69, 1.09, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(674, 64, '2025-10-01', 745.30, 1.13, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(675, 65, '2025-10-01', 754.65, 1.25, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(676, 66, '2025-10-01', 751.22, 1.27, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(677, 67, '2025-10-01', 756.13, 1.25, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(678, 68, '2025-10-01', 742.52, 0.91, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(679, 69, '2025-10-01', 749.42, 1.11, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(680, 70, '2025-10-01', 750.42, 1.16, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(681, 71, '2025-10-01', 749.46, 1.05, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(682, 72, '2025-10-01', 748.93, 1.08, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(683, 73, '2025-10-01', 757.46, 1.52, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(684, 74, '2025-10-01', 759.86, 1.36, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(685, 75, '2025-10-01', 753.91, 1.26, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(686, 76, '2025-10-01', 751.19, 1.08, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(687, 77, '2025-10-01', 747.04, 1.09, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(688, 78, '2025-10-01', 751.65, 1.15, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(689, 79, '2025-10-01', 743.47, 0.92, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(690, 80, '2025-10-01', 750.81, 1.08, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(691, 81, '2025-10-01', 750.28, 3.18, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(692, 82, '2025-10-01', 753.92, 1.21, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(693, 83, '2025-10-01', 746.53, 1.15, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(694, 84, '2025-10-01', 755.10, 1.33, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(695, 85, '2025-10-01', 755.99, 1.37, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(696, 86, '2025-10-01', 747.95, 1.05, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(697, 87, '2025-10-01', 749.12, 1.24, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(698, 88, '2025-10-01', 755.82, 1.45, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(699, 89, '2025-10-01', 748.90, 1.03, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(700, 90, '2025-10-01', 746.15, 1.00, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(701, 91, '2025-10-01', 350.32, 0.69, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(702, 92, '2025-10-01', 352.26, 0.84, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(703, 93, '2025-10-01', 345.04, 0.54, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(704, 94, '2025-10-01', 350.17, 0.82, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(705, 95, '2025-10-01', 352.56, 0.75, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(706, 96, '2025-10-01', 349.74, 0.79, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(707, 97, '2025-10-01', 352.33, 0.69, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(708, 98, '2025-10-01', 350.57, 0.72, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(709, 99, '2025-10-01', 348.50, 0.76, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(710, 100, '2025-10-01', 357.72, 0.92, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(711, 101, '2025-10-01', 350.04, 0.69, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(712, 102, '2025-10-01', 348.16, 0.60, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(713, 103, '2025-10-01', 352.35, 0.86, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(714, 104, '2025-10-01', 352.00, 0.67, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:20', 5),
	(715, 105, '2025-10-01', 344.45, 0.59, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(716, 106, '2025-10-01', 355.98, 0.97, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(717, 107, '2025-10-01', 353.57, 0.81, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(718, 108, '2025-10-01', 352.90, 0.75, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(719, 109, '2025-10-01', 347.42, 0.65, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(720, 110, '2025-10-01', 350.73, 0.80, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(721, 111, '2025-10-01', 177.08, 0.22, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(722, 112, '2025-10-01', 180.43, 0.31, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(723, 113, '2025-10-01', 185.81, 0.59, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(724, 114, '2025-10-01', 178.99, 0.32, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(725, 115, '2025-10-01', 182.64, 0.36, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(726, 116, '2025-10-01', 187.73, 0.73, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(727, 117, '2025-10-01', 182.79, 0.52, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(728, 118, '2025-10-01', 182.15, 0.26, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(729, 119, '2025-10-01', 183.52, 0.48, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(730, 120, '2025-10-01', 180.43, 0.29, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(731, 121, '2025-10-01', 168.80, -0.05, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(732, 122, '2025-10-01', 168.80, -0.07, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(733, 123, '2025-10-01', 188.30, 0.63, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(734, 124, '2025-10-01', 182.07, 0.27, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(735, 125, '2025-10-01', 176.33, 0.14, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(736, 126, '2025-10-01', 182.71, 0.54, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(737, 127, '2025-10-01', 172.53, 0.11, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(738, 128, '2025-10-01', 189.52, 0.62, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(739, 129, '2025-10-01', 177.09, 0.38, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(740, 130, '2025-10-01', 187.69, 0.51, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(741, 146, '2025-10-01', 577.48, 0.38, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(742, 147, '2025-10-01', 580.91, 0.41, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(743, 148, '2025-10-01', 577.64, 0.43, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(744, 149, '2025-10-01', 582.91, 0.46, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(745, 150, '2025-10-01', 577.88, 0.36, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(746, 151, '2025-10-01', 568.97, 1.33, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(747, 152, '2025-10-01', 586.80, 0.71, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(748, 153, '2025-10-01', 574.83, 0.26, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(749, 154, '2025-10-01', 572.55, 0.22, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(750, 155, '2025-10-01', 570.64, 0.06, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(751, 156, '2025-10-01', 581.92, 0.58, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(752, 157, '2025-10-01', 571.31, 0.07, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(753, 158, '2025-10-01', 568.55, 0.12, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(754, 159, '2025-10-01', 580.86, 0.35, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(755, 160, '2025-10-01', 587.75, 0.70, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(756, 161, '2025-10-01', 572.17, 0.21, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(757, 162, '2025-10-01', 573.67, 0.25, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(758, 163, '2025-10-01', 582.81, 0.51, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(759, 164, '2025-10-01', 576.15, 0.32, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(760, 165, '2025-10-01', 572.05, 0.23, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(761, 166, '2025-10-01', 467.63, 0.54, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(762, 167, '2025-10-01', 467.06, 0.54, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(763, 168, '2025-10-01', 471.22, 0.74, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(764, 169, '2025-10-01', 463.97, 0.38, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(765, 170, '2025-10-01', 460.85, 0.36, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(766, 171, '2025-10-01', 469.04, 0.53, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(767, 172, '2025-10-01', 465.42, 0.45, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(768, 173, '2025-10-01', 465.63, 0.45, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(769, 174, '2025-10-01', 463.27, 0.46, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(770, 175, '2025-10-01', 467.95, 0.57, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(771, 176, '2025-10-01', 461.07, 0.35, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(772, 177, '2025-10-01', 462.84, 0.39, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(773, 178, '2025-10-01', 462.03, 0.31, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(774, 179, '2025-10-01', 466.73, 0.59, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(775, 180, '2025-10-01', 472.07, 0.62, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(776, 181, '2025-10-01', 471.11, 0.70, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(777, 182, '2025-10-01', 467.92, 0.60, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(778, 183, '2025-10-01', 461.19, 0.27, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(779, 184, '2025-10-01', 469.46, 0.60, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(780, 185, '2025-10-01', 463.18, 0.35, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(781, 186, '2025-10-01', 463.11, 0.40, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(782, 187, '2025-10-01', 467.52, 0.52, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(783, 188, '2025-10-01', 464.80, 0.40, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(784, 189, '2025-10-01', 467.41, 0.46, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(785, 190, '2025-10-01', 461.47, 0.33, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(786, 131, '2025-10-01', 446.64, 0.51, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(787, 132, '2025-10-01', 430.54, 0.07, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(788, 133, '2025-10-01', 426.50, -0.19, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(789, 134, '2025-10-01', 435.09, 0.11, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(790, 135, '2025-10-01', 433.22, 0.06, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(791, 136, '2025-10-01', 426.50, -0.06, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(792, 137, '2025-10-01', 425.29, -0.07, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(793, 138, '2025-10-01', 440.86, 0.40, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(794, 139, '2025-10-01', 426.50, -0.12, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(795, 140, '2025-10-01', 431.96, 0.06, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(796, 141, '2025-10-01', 418.50, -0.38, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(797, 142, '2025-10-01', 437.32, 0.18, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(798, 143, '2025-10-01', 436.54, 0.17, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(799, 144, '2025-10-01', 432.24, 0.12, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(800, 145, '2025-10-01', 414.68, -0.55, 'import', '5_1770557354.txt', NULL, '2026-02-08 13:29:21', 5),
	(802, 32, '2025-12-01', 592.80, 0.58, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(803, 33, '2025-12-01', 603.50, 0.61, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(804, 34, '2025-12-01', 594.10, 0.71, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(805, 35, '2025-12-01', 596.50, 0.55, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(806, 36, '2025-12-01', 596.90, 0.69, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6);
INSERT INTO public.weighing VALUES
	(807, 37, '2025-12-01', 598.20, 0.56, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(808, 38, '2025-12-01', 593.50, 0.52, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(809, 39, '2025-12-01', 596.00, 0.73, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(810, 40, '2025-12-01', 595.80, 0.58, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(811, 41, '2025-12-01', 594.20, 0.59, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(812, 42, '2025-12-01', 592.50, 0.51, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(813, 43, '2025-12-01', 599.10, 0.56, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(814, 44, '2025-12-01', 595.30, 0.57, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(815, 45, '2025-12-01', 596.80, 0.69, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(816, 46, '2025-12-01', 595.90, 0.54, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:13', 6),
	(817, 47, '2025-12-01', 597.00, 0.65, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(818, 48, '2025-12-01', 598.10, 0.64, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(819, 49, '2025-12-01', 598.50, 0.71, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(820, 50, '2025-12-01', 590.20, 0.44, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(821, 51, '2025-12-01', 589.50, 0.50, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(822, 52, '2025-12-01', 600.10, 0.79, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(823, 53, '2025-12-01', 600.50, 0.64, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(824, 54, '2025-12-01', 601.00, 0.58, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(825, 55, '2025-12-01', 605.20, 0.50, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(826, 56, '2025-12-01', 592.80, 0.56, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(827, 57, '2025-12-01', 595.10, 0.62, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(828, 58, '2025-12-01', 591.00, 0.51, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(829, 59, '2025-12-01', 602.40, 0.80, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(830, 60, '2025-12-01', 602.10, 0.73, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(831, 61, '2025-12-01', 829.50, 1.38, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(832, 62, '2025-12-01', 831.80, 1.33, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(833, 63, '2025-12-01', 830.50, 1.34, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(834, 64, '2025-12-01', 839.20, 1.54, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(835, 65, '2025-12-01', 841.50, 1.42, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(836, 66, '2025-12-01', 832.10, 1.33, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(837, 67, '2025-12-01', 824.80, 1.13, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(838, 68, '2025-12-01', 838.20, 1.57, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(839, 69, '2025-12-01', 824.50, 1.23, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(840, 70, '2025-12-01', 835.60, 1.40, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(841, 71, '2025-12-01', 831.90, 1.35, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(842, 72, '2025-12-01', 823.50, 1.22, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(843, 73, '2025-12-01', 829.80, 1.19, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(844, 74, '2025-12-01', 830.90, 1.17, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(845, 75, '2025-12-01', 823.80, 1.15, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(846, 76, '2025-12-01', 828.90, 1.27, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(847, 77, '2025-12-01', 824.50, 1.27, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(848, 78, '2025-12-01', 815.20, 1.04, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(849, 79, '2025-12-01', 829.50, 1.41, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(850, 80, '2025-12-01', 826.80, 1.25, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(851, 81, '2025-12-01', 829.10, 1.29, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(852, 82, '2025-12-01', 823.90, 1.15, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(853, 83, '2025-12-01', 831.50, 1.39, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(854, 84, '2025-12-01', 828.60, 1.21, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(855, 85, '2025-12-01', 818.50, 1.03, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(856, 86, '2025-12-01', 823.80, 1.24, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(857, 87, '2025-12-01', 826.10, 1.26, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(858, 88, '2025-12-01', 830.80, 1.23, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(859, 89, '2025-12-01', 836.90, 1.44, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(860, 90, '2025-12-01', 835.50, 1.47, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(861, 91, '2025-12-01', 382.50, 0.53, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(862, 92, '2025-12-01', 380.10, 0.46, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(863, 93, '2025-12-01', 383.80, 0.64, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(864, 94, '2025-12-01', 378.20, 0.46, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(865, 95, '2025-12-01', 381.10, 0.47, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(866, 96, '2025-12-01', 381.20, 0.52, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(867, 97, '2025-12-01', 384.50, 0.53, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(868, 98, '2025-12-01', 382.90, 0.53, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(869, 99, '2025-12-01', 382.60, 0.56, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(870, 100, '2025-12-01', 380.20, 0.37, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(871, 101, '2025-12-01', 380.50, 0.50, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(872, 102, '2025-12-01', 378.80, 0.50, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(873, 103, '2025-12-01', 385.10, 0.54, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(874, 104, '2025-12-01', 379.20, 0.45, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(875, 105, '2025-12-01', 385.00, 0.67, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(876, 106, '2025-12-01', 377.50, 0.35, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(877, 107, '2025-12-01', 379.30, 0.42, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(878, 108, '2025-12-01', 384.50, 0.52, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(879, 109, '2025-12-01', 385.90, 0.63, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(880, 110, '2025-12-01', 386.20, 0.58, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(881, 111, '2025-12-01', 208.50, 0.52, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(882, 112, '2025-12-01', 213.10, 0.54, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(883, 113, '2025-12-01', 209.20, 0.38, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(884, 114, '2025-12-01', 214.50, 0.58, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(885, 115, '2025-12-01', 216.20, 0.55, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(886, 116, '2025-12-01', 212.80, 0.41, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(887, 117, '2025-12-01', 216.10, 0.55, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(888, 118, '2025-12-01', 216.90, 0.57, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(889, 119, '2025-12-01', 219.10, 0.58, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(890, 120, '2025-12-01', 216.50, 0.59, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(891, 121, '2025-12-01', 215.20, 0.76, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(892, 122, '2025-12-01', 205.80, 0.61, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(893, 123, '2025-12-01', 213.90, 0.42, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(894, 124, '2025-12-01', 210.50, 0.47, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(895, 125, '2025-12-01', 210.90, 0.57, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(896, 126, '2025-12-01', 206.20, 0.39, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(897, 127, '2025-12-01', 210.80, 0.63, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(898, 128, '2025-12-01', 216.90, 0.45, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(899, 129, '2025-12-01', 214.50, 0.61, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(900, 130, '2025-12-01', 217.10, 0.48, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(901, 146, '2025-12-01', 595.20, 0.29, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(902, 147, '2025-12-01', 588.10, 0.12, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(903, 148, '2025-12-01', 594.80, 0.28, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(904, 149, '2025-12-01', 606.50, 0.39, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(905, 150, '2025-12-01', 603.20, 0.42, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(906, 151, '2025-12-01', 592.10, 0.38, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(907, 152, '2025-12-01', 603.80, 0.28, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(908, 153, '2025-12-01', 597.50, 0.37, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(909, 154, '2025-12-01', 593.50, 0.34, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(910, 155, '2025-12-01', 597.20, 0.44, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(911, 156, '2025-12-01', 595.90, 0.23, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(912, 157, '2025-12-01', 603.90, 0.53, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(913, 158, '2025-12-01', 598.50, 0.49, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(914, 159, '2025-12-01', 593.10, 0.20, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(915, 160, '2025-12-01', 596.20, 0.14, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(916, 161, '2025-12-01', 602.80, 0.50, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(917, 162, '2025-12-01', 602.50, 0.47, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(918, 163, '2025-12-01', 596.10, 0.22, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(919, 164, '2025-12-01', 600.90, 0.41, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(920, 165, '2025-12-01', 599.50, 0.45, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(921, 166, '2025-12-01', 495.50, 0.46, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(922, 167, '2025-12-01', 494.20, 0.45, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(923, 168, '2025-12-01', 490.50, 0.32, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(924, 169, '2025-12-01', 491.50, 0.45, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(925, 170, '2025-12-01', 493.80, 0.54, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(926, 171, '2025-12-01', 501.50, 0.53, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(927, 172, '2025-12-01', 498.50, 0.54, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(928, 173, '2025-12-01', 494.10, 0.47, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(929, 174, '2025-12-01', 498.50, 0.58, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(930, 175, '2025-12-01', 495.90, 0.46, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(931, 176, '2025-12-01', 493.80, 0.54, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(932, 177, '2025-12-01', 494.20, 0.51, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(933, 178, '2025-12-01', 502.10, 0.66, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(934, 179, '2025-12-01', 494.00, 0.45, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(935, 180, '2025-12-01', 496.50, 0.40, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(936, 181, '2025-12-01', 494.50, 0.38, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(937, 182, '2025-12-01', 495.50, 0.45, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(938, 183, '2025-12-01', 497.10, 0.59, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(939, 184, '2025-12-01', 498.80, 0.48, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(940, 185, '2025-12-01', 492.90, 0.49, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(941, 186, '2025-12-01', 494.80, 0.52, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(942, 187, '2025-12-01', 491.90, 0.40, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(943, 188, '2025-12-01', 497.50, 0.54, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(944, 189, '2025-12-01', 497.80, 0.50, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(945, 190, '2025-12-01', 499.10, 0.62, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(946, 131, '2025-12-01', 433.80, -0.21, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(947, 132, '2025-12-01', 428.20, -0.04, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(948, 133, '2025-12-01', 429.10, 0.04, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(949, 134, '2025-12-01', 428.10, -0.12, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(950, 135, '2025-12-01', 428.20, -0.08, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(951, 136, '2025-12-01', 439.50, 0.21, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(952, 137, '2025-12-01', 434.50, 0.15, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(953, 138, '2025-12-01', 443.20, 0.04, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(954, 139, '2025-12-01', 438.20, 0.19, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(955, 140, '2025-12-01', 439.90, 0.13, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(956, 141, '2025-12-01', 439.50, 0.34, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(957, 142, '2025-12-01', 439.50, 0.04, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(958, 143, '2025-12-01', 433.90, -0.04, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(959, 144, '2025-12-01', 437.50, 0.09, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(960, 145, '2025-12-01', 432.90, 0.30, 'import', '6_1770557407.txt', NULL, '2026-02-08 13:30:14', 6),
	(962, 32, '2026-01-01', 610.58, 0.57, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(963, 33, '2026-01-01', 621.61, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(964, 34, '2026-01-01', 611.92, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(965, 35, '2026-01-01', 614.40, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(966, 36, '2026-01-01', 614.81, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(967, 37, '2026-01-01', 616.15, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(968, 38, '2026-01-01', 611.31, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(969, 39, '2026-01-01', 613.88, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(970, 40, '2026-01-01', 613.67, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(971, 41, '2026-01-01', 612.03, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(972, 42, '2026-01-01', 610.27, 0.57, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(973, 43, '2026-01-01', 617.07, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(974, 44, '2026-01-01', 613.16, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(975, 45, '2026-01-01', 614.70, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(976, 46, '2026-01-01', 613.78, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(977, 47, '2026-01-01', 614.91, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(978, 48, '2026-01-01', 616.04, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(979, 49, '2026-01-01', 616.45, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(980, 50, '2026-01-01', 607.91, 0.57, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(981, 51, '2026-01-01', 607.19, 0.57, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(982, 52, '2026-01-01', 618.10, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(983, 53, '2026-01-01', 618.51, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(984, 54, '2026-01-01', 619.03, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(985, 55, '2026-01-01', 623.35, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(986, 56, '2026-01-01', 610.58, 0.57, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(987, 57, '2026-01-01', 612.95, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(988, 58, '2026-01-01', 608.73, 0.57, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(989, 59, '2026-01-01', 620.47, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(990, 60, '2026-01-01', 620.16, 0.58, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(991, 61, '2026-01-01', 869.50, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(992, 62, '2026-01-01', 871.91, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(993, 63, '2026-01-01', 870.55, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(994, 64, '2026-01-01', 879.67, 1.31, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(995, 65, '2026-01-01', 882.08, 1.31, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(996, 66, '2026-01-01', 872.23, 1.30, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(997, 67, '2026-01-01', 864.57, 1.28, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(998, 68, '2026-01-01', 878.62, 1.30, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(999, 69, '2026-01-01', 864.26, 1.28, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1000, 70, '2026-01-01', 875.90, 1.30, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1001, 71, '2026-01-01', 872.02, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1002, 72, '2026-01-01', 863.21, 1.28, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1003, 73, '2026-01-01', 869.82, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1004, 74, '2026-01-01', 870.97, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1005, 75, '2026-01-01', 863.52, 1.28, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1006, 76, '2026-01-01', 868.87, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1007, 77, '2026-01-01', 864.26, 1.28, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7);
INSERT INTO public.weighing VALUES
	(1008, 78, '2026-01-01', 854.51, 1.27, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1009, 79, '2026-01-01', 869.50, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1010, 80, '2026-01-01', 866.67, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1011, 81, '2026-01-01', 869.08, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1012, 82, '2026-01-01', 863.63, 1.28, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1013, 83, '2026-01-01', 871.60, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1014, 84, '2026-01-01', 868.55, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1015, 85, '2026-01-01', 857.97, 1.27, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1016, 86, '2026-01-01', 863.52, 1.28, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1017, 87, '2026-01-01', 865.93, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1018, 88, '2026-01-01', 870.86, 1.29, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1019, 89, '2026-01-01', 877.26, 1.30, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1020, 90, '2026-01-01', 875.79, 1.30, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1021, 91, '2026-01-01', 400.95, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1022, 92, '2026-01-01', 398.43, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1023, 93, '2026-01-01', 402.31, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1024, 94, '2026-01-01', 396.44, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1025, 95, '2026-01-01', 399.48, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1026, 96, '2026-01-01', 399.59, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1027, 97, '2026-01-01', 403.05, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1028, 98, '2026-01-01', 401.37, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1029, 99, '2026-01-01', 401.06, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1030, 100, '2026-01-01', 398.54, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1031, 101, '2026-01-01', 398.85, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1032, 102, '2026-01-01', 397.07, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1033, 103, '2026-01-01', 403.68, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1034, 104, '2026-01-01', 397.49, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1035, 105, '2026-01-01', 403.57, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1036, 106, '2026-01-01', 395.71, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1037, 107, '2026-01-01', 397.59, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1038, 108, '2026-01-01', 403.05, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1039, 109, '2026-01-01', 404.51, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1040, 110, '2026-01-01', 404.83, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1041, 111, '2026-01-01', 230.19, 0.70, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1042, 112, '2026-01-01', 235.27, 0.72, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1043, 113, '2026-01-01', 230.96, 0.70, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1044, 114, '2026-01-01', 236.82, 0.72, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1045, 115, '2026-01-01', 238.69, 0.73, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1046, 116, '2026-01-01', 234.94, 0.71, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1047, 117, '2026-01-01', 238.58, 0.73, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1048, 118, '2026-01-01', 239.47, 0.73, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1049, 119, '2026-01-01', 241.90, 0.74, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1050, 120, '2026-01-01', 239.02, 0.73, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1051, 121, '2026-01-01', 237.59, 0.72, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1052, 122, '2026-01-01', 227.20, 0.69, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1053, 123, '2026-01-01', 236.15, 0.72, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1054, 124, '2026-01-01', 232.39, 0.71, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1055, 125, '2026-01-01', 232.84, 0.71, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1056, 126, '2026-01-01', 227.65, 0.69, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1057, 127, '2026-01-01', 232.73, 0.71, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1058, 128, '2026-01-01', 239.47, 0.73, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1059, 129, '2026-01-01', 236.82, 0.72, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1060, 130, '2026-01-01', 239.69, 0.73, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1061, 146, '2026-01-01', 607.70, 0.40, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1062, 147, '2026-01-01', 600.46, 0.40, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1063, 148, '2026-01-01', 607.30, 0.40, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1064, 149, '2026-01-01', 619.23, 0.41, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1065, 150, '2026-01-01', 615.86, 0.41, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1066, 151, '2026-01-01', 604.54, 0.40, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1067, 152, '2026-01-01', 616.48, 0.41, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1068, 153, '2026-01-01', 610.05, 0.41, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1069, 154, '2026-01-01', 605.97, 0.40, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1070, 155, '2026-01-01', 609.74, 0.41, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1071, 156, '2026-01-01', 608.42, 0.40, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1072, 157, '2026-01-01', 616.58, 0.41, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1073, 158, '2026-01-01', 611.07, 0.41, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1074, 159, '2026-01-01', 605.56, 0.40, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1075, 160, '2026-01-01', 608.72, 0.40, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1076, 161, '2026-01-01', 615.46, 0.41, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1077, 162, '2026-01-01', 615.15, 0.41, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1078, 163, '2026-01-01', 608.62, 0.40, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1079, 164, '2026-01-01', 613.52, 0.41, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1080, 165, '2026-01-01', 612.09, 0.41, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1081, 166, '2026-01-01', 514.07, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1082, 167, '2026-01-01', 512.72, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1083, 168, '2026-01-01', 508.88, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1084, 169, '2026-01-01', 509.92, 0.59, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1085, 170, '2026-01-01', 512.31, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1086, 171, '2026-01-01', 520.30, 0.61, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1087, 172, '2026-01-01', 517.18, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1088, 173, '2026-01-01', 512.62, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1089, 174, '2026-01-01', 517.18, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1090, 175, '2026-01-01', 514.49, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1091, 176, '2026-01-01', 512.31, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1092, 177, '2026-01-01', 512.72, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1093, 178, '2026-01-01', 520.92, 0.61, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1094, 179, '2026-01-01', 512.51, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1095, 180, '2026-01-01', 515.11, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1096, 181, '2026-01-01', 513.03, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1097, 182, '2026-01-01', 514.07, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1098, 183, '2026-01-01', 515.73, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1099, 184, '2026-01-01', 517.50, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1100, 185, '2026-01-01', 511.37, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1101, 186, '2026-01-01', 513.34, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1102, 187, '2026-01-01', 510.33, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1103, 188, '2026-01-01', 516.15, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1104, 189, '2026-01-01', 516.46, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1105, 190, '2026-01-01', 517.81, 0.60, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1106, 131, '2026-01-01', 437.05, 0.11, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1107, 132, '2026-01-01', 431.41, 0.10, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1108, 133, '2026-01-01', 432.32, 0.10, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1109, 134, '2026-01-01', 431.31, 0.10, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1110, 135, '2026-01-01', 431.41, 0.10, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1111, 136, '2026-01-01', 442.80, 0.11, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1112, 137, '2026-01-01', 437.76, 0.11, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1113, 138, '2026-01-01', 446.52, 0.11, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1114, 139, '2026-01-01', 441.49, 0.11, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1115, 140, '2026-01-01', 443.20, 0.11, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1116, 141, '2026-01-01', 442.80, 0.11, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1117, 142, '2026-01-01', 442.80, 0.11, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1118, 143, '2026-01-01', 437.15, 0.11, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1119, 144, '2026-01-01', 440.78, 0.11, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1120, 145, '2026-01-01', 436.15, 0.11, 'import', '7_1770557524.txt', NULL, '2026-02-08 13:32:12', 7),
	(1121, 60, '2026-02-08', 76.00, -14.32, 'manual', NULL, NULL, '2026-02-08 18:31:06', 8),
	(1122, 145, '2026-02-08', 165.00, -7.14, 'manual', NULL, NULL, '2026-02-08 18:31:39', 9),
	(1124, 32, '2026-01-01', 610.58, 0.57, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1125, 33, '2026-01-01', 621.61, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1126, 34, '2026-01-01', 611.92, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1127, 35, '2026-01-01', 614.40, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1128, 36, '2026-01-01', 614.81, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1129, 37, '2026-01-01', 616.15, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1130, 38, '2026-01-01', 611.31, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1131, 39, '2026-01-01', 613.88, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1132, 40, '2026-01-01', 613.67, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1133, 41, '2026-01-01', 612.03, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1134, 42, '2026-01-01', 610.27, 0.57, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1135, 43, '2026-01-01', 617.07, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1136, 44, '2026-01-01', 613.16, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1137, 45, '2026-01-01', 614.70, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1138, 46, '2026-01-01', 613.78, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1139, 47, '2026-01-01', 614.91, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1140, 48, '2026-01-01', 616.04, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1141, 49, '2026-01-01', 616.45, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1142, 50, '2026-01-01', 607.91, 0.57, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1143, 51, '2026-01-01', 607.19, 0.57, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1144, 52, '2026-01-01', 618.10, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1145, 53, '2026-01-01', 618.51, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1146, 54, '2026-01-01', 619.03, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1147, 55, '2026-01-01', 623.35, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1148, 56, '2026-01-01', 610.58, 0.57, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1149, 57, '2026-01-01', 612.95, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1150, 58, '2026-01-01', 608.73, 0.57, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1151, 59, '2026-01-01', 620.47, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1152, 60, '2026-01-01', 620.16, 0.58, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1153, 61, '2026-01-01', 869.50, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1154, 62, '2026-01-01', 871.91, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1155, 63, '2026-01-01', 870.55, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1156, 64, '2026-01-01', 879.67, 1.31, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1157, 65, '2026-01-01', 882.08, 1.31, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1158, 66, '2026-01-01', 872.23, 1.30, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1159, 67, '2026-01-01', 864.57, 1.28, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1160, 68, '2026-01-01', 878.62, 1.30, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1161, 69, '2026-01-01', 864.26, 1.28, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1162, 70, '2026-01-01', 875.90, 1.30, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1163, 71, '2026-01-01', 872.02, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1164, 72, '2026-01-01', 863.21, 1.28, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1165, 73, '2026-01-01', 869.82, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1166, 74, '2026-01-01', 870.97, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1167, 75, '2026-01-01', 863.52, 1.28, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1168, 76, '2026-01-01', 868.87, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1169, 77, '2026-01-01', 864.26, 1.28, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1170, 78, '2026-01-01', 854.51, 1.27, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1171, 79, '2026-01-01', 869.50, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1172, 80, '2026-01-01', 866.67, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1173, 81, '2026-01-01', 869.08, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1174, 82, '2026-01-01', 863.63, 1.28, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1175, 83, '2026-01-01', 871.60, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1176, 84, '2026-01-01', 868.55, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1177, 85, '2026-01-01', 857.97, 1.27, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1178, 86, '2026-01-01', 863.52, 1.28, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1179, 87, '2026-01-01', 865.93, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1180, 88, '2026-01-01', 870.86, 1.29, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1181, 89, '2026-01-01', 877.26, 1.30, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1182, 90, '2026-01-01', 875.79, 1.30, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1183, 91, '2026-01-01', 400.95, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1184, 92, '2026-01-01', 398.43, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1185, 93, '2026-01-01', 402.31, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1186, 94, '2026-01-01', 396.44, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1187, 95, '2026-01-01', 399.48, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1188, 96, '2026-01-01', 399.59, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1189, 97, '2026-01-01', 403.05, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1190, 98, '2026-01-01', 401.37, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1191, 99, '2026-01-01', 401.06, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1192, 100, '2026-01-01', 398.54, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1193, 101, '2026-01-01', 398.85, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1194, 102, '2026-01-01', 397.07, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1195, 103, '2026-01-01', 403.68, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1196, 104, '2026-01-01', 397.49, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1197, 105, '2026-01-01', 403.57, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1198, 106, '2026-01-01', 395.71, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1199, 107, '2026-01-01', 397.59, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1200, 108, '2026-01-01', 403.05, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1201, 109, '2026-01-01', 404.51, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1202, 110, '2026-01-01', 404.83, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1203, 111, '2026-01-01', 230.19, 0.70, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1204, 112, '2026-01-01', 235.27, 0.72, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1205, 113, '2026-01-01', 230.96, 0.70, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1206, 114, '2026-01-01', 236.82, 0.72, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1207, 115, '2026-01-01', 238.69, 0.73, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1208, 116, '2026-01-01', 234.94, 0.71, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10);
INSERT INTO public.weighing VALUES
	(1209, 117, '2026-01-01', 238.58, 0.73, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1210, 118, '2026-01-01', 239.47, 0.73, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1211, 119, '2026-01-01', 241.90, 0.74, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1212, 120, '2026-01-01', 239.02, 0.73, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1213, 121, '2026-01-01', 237.59, 0.72, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1214, 122, '2026-01-01', 227.20, 0.69, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1215, 123, '2026-01-01', 236.15, 0.72, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1216, 124, '2026-01-01', 232.39, 0.71, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1217, 125, '2026-01-01', 232.84, 0.71, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1218, 126, '2026-01-01', 227.65, 0.69, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1219, 127, '2026-01-01', 232.73, 0.71, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1220, 128, '2026-01-01', 239.47, 0.73, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1221, 129, '2026-01-01', 236.82, 0.72, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1222, 130, '2026-01-01', 239.69, 0.73, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1223, 146, '2026-01-01', 607.70, 0.40, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1224, 147, '2026-01-01', 600.46, 0.40, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1225, 148, '2026-01-01', 607.30, 0.40, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1226, 149, '2026-01-01', 619.23, 0.41, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1227, 150, '2026-01-01', 615.86, 0.41, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1228, 151, '2026-01-01', 604.54, 0.40, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1229, 152, '2026-01-01', 616.48, 0.41, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1230, 153, '2026-01-01', 610.05, 0.41, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1231, 154, '2026-01-01', 605.97, 0.40, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1232, 155, '2026-01-01', 609.74, 0.41, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1233, 156, '2026-01-01', 608.42, 0.40, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1234, 157, '2026-01-01', 616.58, 0.41, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1235, 158, '2026-01-01', 611.07, 0.41, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1236, 159, '2026-01-01', 605.56, 0.40, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1237, 160, '2026-01-01', 608.72, 0.40, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1238, 161, '2026-01-01', 615.46, 0.41, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1239, 162, '2026-01-01', 615.15, 0.41, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1240, 163, '2026-01-01', 608.62, 0.40, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1241, 164, '2026-01-01', 613.52, 0.41, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1242, 165, '2026-01-01', 612.09, 0.41, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1243, 166, '2026-01-01', 514.07, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1244, 167, '2026-01-01', 512.72, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1245, 168, '2026-01-01', 508.88, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1246, 169, '2026-01-01', 509.92, 0.59, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1247, 170, '2026-01-01', 512.31, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1248, 171, '2026-01-01', 520.30, 0.61, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1249, 172, '2026-01-01', 517.18, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1250, 173, '2026-01-01', 512.62, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1251, 174, '2026-01-01', 517.18, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1252, 175, '2026-01-01', 514.49, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1253, 176, '2026-01-01', 512.31, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1254, 177, '2026-01-01', 512.72, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1255, 178, '2026-01-01', 520.92, 0.61, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1256, 179, '2026-01-01', 512.51, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1257, 180, '2026-01-01', 515.11, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1258, 181, '2026-01-01', 513.03, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1259, 182, '2026-01-01', 514.07, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1260, 183, '2026-01-01', 515.73, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1261, 184, '2026-01-01', 517.50, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1262, 185, '2026-01-01', 511.37, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1263, 186, '2026-01-01', 513.34, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1264, 187, '2026-01-01', 510.33, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1265, 188, '2026-01-01', 516.15, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1266, 189, '2026-01-01', 516.46, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1267, 190, '2026-01-01', 517.81, 0.60, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1268, 131, '2026-01-01', 437.05, 0.11, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1269, 132, '2026-01-01', 431.41, 0.10, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1270, 133, '2026-01-01', 432.32, 0.10, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1271, 134, '2026-01-01', 431.31, 0.10, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1272, 135, '2026-01-01', 431.41, 0.10, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1273, 136, '2026-01-01', 442.80, 0.11, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1274, 137, '2026-01-01', 437.76, 0.11, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1275, 138, '2026-01-01', 446.52, 0.11, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1276, 139, '2026-01-01', 441.49, 0.11, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1277, 140, '2026-01-01', 443.20, 0.11, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1278, 141, '2026-01-01', 442.80, 0.11, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1279, 142, '2026-01-01', 442.80, 0.11, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1280, 143, '2026-01-01', 437.15, 0.11, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1281, 144, '2026-01-01', 440.78, 0.11, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1282, 145, '2026-01-01', 436.15, 0.11, 'import', '7_1770575650.txt', NULL, '2026-02-08 18:34:19', 10),
	(1284, 32, '2026-02-08', 631.20, 0.54, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1285, 33, '2026-02-08', 642.80, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1286, 34, '2026-02-08', 632.50, 0.54, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1287, 35, '2026-02-08', 635.10, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1288, 36, '2026-02-08', 635.90, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1289, 37, '2026-02-08', 637.40, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1290, 38, '2026-02-08', 632.10, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1291, 39, '2026-02-08', 634.80, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1292, 40, '2026-02-08', 634.50, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1293, 41, '2026-02-08', 632.90, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1294, 42, '2026-02-08', 631.00, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1295, 43, '2026-02-08', 638.20, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1296, 44, '2026-02-08', 634.00, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1297, 45, '2026-02-08', 635.60, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1298, 46, '2026-02-08', 634.90, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1299, 47, '2026-02-08', 636.00, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1300, 48, '2026-02-08', 637.20, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1301, 49, '2026-02-08', 637.80, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1302, 50, '2026-02-08', 628.50, 0.54, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1303, 51, '2026-02-08', 627.90, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1304, 52, '2026-02-08', 639.10, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1305, 53, '2026-02-08', 639.50, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1306, 54, '2026-02-08', 640.20, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1307, 55, '2026-02-08', 644.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1308, 56, '2026-02-08', 631.50, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1309, 57, '2026-02-08', 633.80, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1310, 58, '2026-02-08', 629.50, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1311, 59, '2026-02-08', 641.50, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1312, 60, '2026-02-08', 641.20, 0.55, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1313, 61, '2026-02-08', 915.50, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1314, 62, '2026-02-08', 918.20, 1.22, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1315, 63, '2026-02-08', 916.80, 1.22, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1316, 64, '2026-02-08', 925.50, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1317, 65, '2026-02-08', 928.10, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1318, 66, '2026-02-08', 918.50, 1.22, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1319, 67, '2026-02-08', 910.20, 1.20, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1320, 68, '2026-02-08', 924.80, 1.22, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1321, 69, '2026-02-08', 910.10, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1322, 70, '2026-02-08', 921.50, 1.20, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1323, 71, '2026-02-08', 918.20, 1.22, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1324, 72, '2026-02-08', 908.50, 1.19, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1325, 73, '2026-02-08', 915.90, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1326, 74, '2026-02-08', 916.80, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1327, 75, '2026-02-08', 909.50, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1328, 76, '2026-02-08', 914.80, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1329, 77, '2026-02-08', 910.10, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1330, 78, '2026-02-08', 900.50, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1331, 79, '2026-02-08', 915.20, 1.20, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1332, 80, '2026-02-08', 912.80, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1333, 81, '2026-02-08', 915.10, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1334, 82, '2026-02-08', 909.20, 1.20, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1335, 83, '2026-02-08', 917.50, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1336, 84, '2026-02-08', 914.80, 1.22, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1337, 85, '2026-02-08', 903.50, 1.20, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1338, 86, '2026-02-08', 909.10, 1.20, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1339, 87, '2026-02-08', 911.80, 1.21, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1340, 88, '2026-02-08', 916.50, 1.20, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1341, 89, '2026-02-08', 922.90, 1.20, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1342, 90, '2026-02-08', 921.50, 1.20, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1343, 91, '2026-02-08', 422.50, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1344, 92, '2026-02-08', 419.80, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1345, 93, '2026-02-08', 423.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1346, 94, '2026-02-08', 417.80, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1347, 95, '2026-02-08', 420.90, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1348, 96, '2026-02-08', 421.10, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1349, 97, '2026-02-08', 424.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1350, 98, '2026-02-08', 422.80, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1351, 99, '2026-02-08', 422.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1352, 100, '2026-02-08', 419.90, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1353, 101, '2026-02-08', 420.20, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1354, 102, '2026-02-08', 418.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1355, 103, '2026-02-08', 425.10, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1356, 104, '2026-02-08', 418.80, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1357, 105, '2026-02-08', 425.00, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1358, 106, '2026-02-08', 416.90, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1359, 107, '2026-02-08', 418.80, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1360, 108, '2026-02-08', 424.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1361, 109, '2026-02-08', 425.90, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1362, 110, '2026-02-08', 426.20, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1363, 111, '2026-02-08', 255.50, 0.67, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1364, 112, '2026-02-08', 260.80, 0.67, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1365, 113, '2026-02-08', 256.20, 0.66, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1366, 114, '2026-02-08', 262.50, 0.68, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1367, 115, '2026-02-08', 264.50, 0.68, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1368, 116, '2026-02-08', 260.50, 0.67, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1369, 117, '2026-02-08', 264.20, 0.67, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1370, 118, '2026-02-08', 265.50, 0.69, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1371, 119, '2026-02-08', 267.80, 0.68, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1372, 120, '2026-02-08', 264.90, 0.68, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1373, 121, '2026-02-08', 263.50, 0.68, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1374, 122, '2026-02-08', 252.80, 0.67, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1375, 123, '2026-02-08', 261.90, 0.68, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1376, 124, '2026-02-08', 258.20, 0.68, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1377, 125, '2026-02-08', 258.50, 0.68, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1378, 126, '2026-02-08', 253.20, 0.67, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1379, 127, '2026-02-08', 258.50, 0.68, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1380, 128, '2026-02-08', 265.50, 0.69, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1381, 129, '2026-02-08', 262.80, 0.68, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1382, 130, '2026-02-08', 265.80, 0.69, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1383, 146, '2026-02-08', 621.50, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1384, 147, '2026-02-08', 614.20, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1385, 148, '2026-02-08', 621.10, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1386, 149, '2026-02-08', 633.50, 0.38, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1387, 150, '2026-02-08', 629.80, 0.37, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1388, 151, '2026-02-08', 618.20, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1389, 152, '2026-02-08', 630.50, 0.37, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1390, 153, '2026-02-08', 623.90, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1391, 154, '2026-02-08', 619.80, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1392, 155, '2026-02-08', 623.50, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1393, 156, '2026-02-08', 622.20, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1394, 157, '2026-02-08', 630.50, 0.37, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1395, 158, '2026-02-08', 624.90, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1396, 159, '2026-02-08', 619.20, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1397, 160, '2026-02-08', 622.50, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1398, 161, '2026-02-08', 629.50, 0.37, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1399, 162, '2026-02-08', 629.10, 0.37, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1400, 163, '2026-02-08', 622.50, 0.37, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1401, 164, '2026-02-08', 627.50, 0.37, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1402, 165, '2026-02-08', 625.90, 0.36, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1403, 166, '2026-02-08', 535.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1404, 167, '2026-02-08', 534.20, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1405, 168, '2026-02-08', 530.50, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1406, 169, '2026-02-08', 531.50, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1407, 170, '2026-02-08', 533.80, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1408, 171, '2026-02-08', 541.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1409, 172, '2026-02-08', 538.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11);
INSERT INTO public.weighing VALUES
	(1410, 173, '2026-02-08', 534.10, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1411, 174, '2026-02-08', 538.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1412, 175, '2026-02-08', 535.90, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1413, 176, '2026-02-08', 533.80, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1414, 177, '2026-02-08', 534.20, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1415, 178, '2026-02-08', 542.10, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1416, 179, '2026-02-08', 534.00, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1417, 180, '2026-02-08', 536.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1418, 181, '2026-02-08', 534.50, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1419, 182, '2026-02-08', 535.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1420, 183, '2026-02-08', 537.10, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1421, 184, '2026-02-08', 538.80, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1422, 185, '2026-02-08', 532.90, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1423, 186, '2026-02-08', 534.80, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1424, 187, '2026-02-08', 531.90, 0.57, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1425, 188, '2026-02-08', 537.50, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1426, 189, '2026-02-08', 537.80, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1427, 190, '2026-02-08', 539.10, 0.56, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1428, 131, '2026-02-08', 440.50, 0.09, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1429, 132, '2026-02-08', 434.80, 0.09, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1430, 133, '2026-02-08', 435.90, 0.09, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1431, 134, '2026-02-08', 434.80, 0.09, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1432, 135, '2026-02-08', 434.90, 0.09, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1433, 136, '2026-02-08', 446.50, 0.10, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1434, 137, '2026-02-08', 441.20, 0.09, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1435, 138, '2026-02-08', 450.10, 0.09, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1436, 139, '2026-02-08', 445.00, 0.09, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1437, 140, '2026-02-08', 446.80, 0.10, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1438, 141, '2026-02-08', 446.50, 0.10, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1439, 142, '2026-02-08', 446.50, 0.10, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1440, 143, '2026-02-08', 440.90, 0.10, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1441, 144, '2026-02-08', 444.20, 0.09, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1442, 145, '2026-02-08', 439.80, 0.10, 'import', '8_1770642399.txt', NULL, '2026-02-09 13:06:53', 11),
	(1449, 31, '2025-12-13', 450.00, NULL, 'manual', NULL, NULL, '2026-02-11 00:58:37', NULL),
	(1450, 31, '2026-01-12', 485.00, NULL, 'manual', NULL, NULL, '2026-02-11 00:58:37', NULL),
	(1451, 31, '2026-02-11', 470.00, NULL, 'manual', NULL, NULL, '2026-02-11 00:58:37', NULL),
	(1452, 141, '2026-02-12', 500.00, 13.38, 'manual', NULL, NULL, '2026-02-12 12:29:47', 12);

-- Data for Name: weighing_operations; Type: TABLE DATA; Schema: public; Owner: -

INSERT INTO public.weighing_operations VALUES
	(1, 'import', '2026-02-08 13:27:16', '1_1770557227.txt', 160, 6),
	(2, 'import', '2026-02-08 13:27:49', '2_1770557262.txt', 160, 6),
	(3, 'import', '2026-02-08 13:28:17', '3_1770557289.txt', 160, 6),
	(4, 'import', '2026-02-08 13:28:42', '4_1770557316.txt', 160, 6),
	(5, 'import', '2026-02-08 13:29:20', '5_1770557354.txt', 160, 6),
	(6, 'import', '2026-02-08 13:30:13', '6_1770557407.txt', 160, 6),
	(7, 'import', '2026-02-08 13:32:12', '7_1770557524.txt', 160, 6),
	(8, 'manual', '2026-02-08 18:31:06', NULL, 1, 7),
	(9, 'manual', '2026-02-08 18:31:39', NULL, 1, 7),
	(10, 'import', '2026-02-08 18:34:19', '7_1770575650.txt', 160, 7),
	(11, 'import', '2026-02-09 13:06:52', '8_1770642399.txt', 160, 6),
	(12, 'manual', '2026-02-12 12:29:47', NULL, 1, 6);

-- Name: accounts_payable_payable_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.accounts_payable_payable_id_seq', 21, true);

-- Name: animal_animal_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.animal_animal_id_seq', 190, true);

-- Name: animal_types_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.animal_types_type_id_seq', 10, true);

-- Name: clients_client_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.clients_client_id_seq', 20, true);

-- Name: company_company_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.company_company_id_seq', 9, true);

-- Name: daily_feeding_feeding_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.daily_feeding_feeding_id_seq', 50, true);

-- Name: european_countries_country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.european_countries_country_id_seq', 39, true);

-- Name: events_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.events_event_id_seq', 1, true);

-- Name: feed_feed_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.feed_feed_id_seq', 3, true);

-- Name: financial_categories_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.financial_categories_category_id_seq', 8, true);

-- Name: health_records_record_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.health_records_record_id_seq', 396, true);

-- Name: login_attempts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.login_attempts_id_seq', 1, true);

-- Name: lot_lot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.lot_lot_id_seq', 22, true);

-- Name: market_prices_price_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.market_prices_price_id_seq', 1, true);

-- Name: medical_catalog_item_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.medical_catalog_item_id_seq', 28, true);

-- Name: operational_costs_cost_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.operational_costs_cost_id_seq', 1, true);

-- Name: sales_sale_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.sales_sale_id_seq', 16, true);

-- Name: suppliers_supplier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.suppliers_supplier_id_seq', 17, true);

-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.users_user_id_seq', 1, true);

-- Name: weighing_operations_operation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.weighing_operations_operation_id_seq', 12, true);

-- Name: weighing_weighing_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -

SELECT pg_catalog.setval('public.weighing_weighing_id_seq', 1452, true);

-- Name: accounts_payable idx_16743_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT idx_16743_primary PRIMARY KEY (payable_id);

-- Name: animal idx_16754_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT idx_16754_primary PRIMARY KEY (animal_id);

-- Name: animal_types idx_16763_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.animal_types
    ADD CONSTRAINT idx_16763_primary PRIMARY KEY (type_id);

-- Name: clients idx_16771_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.clients
    ADD CONSTRAINT idx_16771_primary PRIMARY KEY (client_id);

-- Name: company idx_16782_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.company
    ADD CONSTRAINT idx_16782_primary PRIMARY KEY (company_id);

-- Name: daily_feeding idx_16797_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.daily_feeding
    ADD CONSTRAINT idx_16797_primary PRIMARY KEY (feeding_id);

-- Name: european_countries idx_16802_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.european_countries
    ADD CONSTRAINT idx_16802_primary PRIMARY KEY (country_id);

-- Name: events idx_16807_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.events
    ADD CONSTRAINT idx_16807_primary PRIMARY KEY (event_id);

-- Name: feed idx_16814_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.feed
    ADD CONSTRAINT idx_16814_primary PRIMARY KEY (feed_id);

-- Name: financial_categories idx_16823_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.financial_categories
    ADD CONSTRAINT idx_16823_primary PRIMARY KEY (category_id);

-- Name: health_records idx_16830_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.health_records
    ADD CONSTRAINT idx_16830_primary PRIMARY KEY (record_id);

-- Name: login_attempts idx_16840_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.login_attempts
    ADD CONSTRAINT idx_16840_primary PRIMARY KEY (id);

-- Name: lot idx_16845_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.lot
    ADD CONSTRAINT idx_16845_primary PRIMARY KEY (lot_id);

-- Name: lot_animals idx_16851_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.lot_animals
    ADD CONSTRAINT idx_16851_primary PRIMARY KEY (lot_id, animal_id);

-- Name: market_prices idx_16855_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.market_prices
    ADD CONSTRAINT idx_16855_primary PRIMARY KEY (price_id);

-- Name: medical_catalog idx_16863_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.medical_catalog
    ADD CONSTRAINT idx_16863_primary PRIMARY KEY (item_id);

-- Name: operational_costs idx_16875_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.operational_costs
    ADD CONSTRAINT idx_16875_primary PRIMARY KEY (cost_id);

-- Name: sales idx_16882_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT idx_16882_primary PRIMARY KEY (sale_id);

-- Name: suppliers idx_16889_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT idx_16889_primary PRIMARY KEY (supplier_id);

-- Name: users idx_16901_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.users
    ADD CONSTRAINT idx_16901_primary PRIMARY KEY (user_id);

-- Name: weighing idx_16911_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.weighing
    ADD CONSTRAINT idx_16911_primary PRIMARY KEY (weighing_id);

-- Name: weighing_operations idx_16921_primary; Type: CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.weighing_operations
    ADD CONSTRAINT idx_16921_primary PRIMARY KEY (operation_id);

-- Name: idx_16743_category_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16743_category_id ON public.accounts_payable USING btree (category_id);

-- Name: idx_16743_supplier_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16743_supplier_id ON public.accounts_payable USING btree (supplier_id);

-- Name: idx_16754_country_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16754_country_id ON public.animal USING btree (country_id);

-- Name: idx_16754_tag_number; Type: INDEX; Schema: public; Owner: -

CREATE UNIQUE INDEX idx_16754_tag_number ON public.animal USING btree (tag_number);

-- Name: idx_16754_tag_number_2; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16754_tag_number_2 ON public.animal USING btree (tag_number);

-- Name: idx_16754_type_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16754_type_id ON public.animal USING btree (type_id);

-- Name: idx_16797_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16797_animal_id ON public.daily_feeding USING btree (animal_id);

-- Name: idx_16797_feed_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16797_feed_id ON public.daily_feeding USING btree (feed_id);

-- Name: idx_16802_country_name; Type: INDEX; Schema: public; Owner: -

CREATE UNIQUE INDEX idx_16802_country_name ON public.european_countries USING btree (country_name);

-- Name: idx_16807_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16807_animal_id ON public.events USING btree (animal_id);

-- Name: idx_16814_supplier_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16814_supplier_id ON public.feed USING btree (supplier_id);

-- Name: idx_16830_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16830_animal_id ON public.health_records USING btree (animal_id);

-- Name: idx_16830_item_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16830_item_id ON public.health_records USING btree (item_id);

-- Name: idx_16840_idx_ip_time; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16840_idx_ip_time ON public.login_attempts USING btree (ip, attempted_at);

-- Name: idx_16845_name; Type: INDEX; Schema: public; Owner: -

CREATE UNIQUE INDEX idx_16845_name ON public.lot USING btree (name);

-- Name: idx_16851_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16851_animal_id ON public.lot_animals USING btree (animal_id);

-- Name: idx_16863_supplier_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16863_supplier_id ON public.medical_catalog USING btree (supplier_id);

-- Name: idx_16875_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16875_animal_id ON public.operational_costs USING btree (animal_id);

-- Name: idx_16875_lot_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16875_lot_id ON public.operational_costs USING btree (lot_id);

-- Name: idx_16882_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16882_animal_id ON public.sales USING btree (animal_id);

-- Name: idx_16882_client_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16882_client_id ON public.sales USING btree (client_id);

-- Name: idx_16901_username; Type: INDEX; Schema: public; Owner: -

CREATE UNIQUE INDEX idx_16901_username ON public.users USING btree (username);

-- Name: idx_16911_animal_id; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16911_animal_id ON public.weighing USING btree (animal_id);

-- Name: idx_16911_fk_weighing_op; Type: INDEX; Schema: public; Owner: -

CREATE INDEX idx_16911_fk_weighing_op ON public.weighing USING btree (operation_id);

-- Name: accounts_payable accounts_payable_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_ibfk_1 FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: accounts_payable accounts_payable_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.accounts_payable
    ADD CONSTRAINT accounts_payable_ibfk_2 FOREIGN KEY (category_id) REFERENCES public.financial_categories(category_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: animal animal_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_ibfk_1 FOREIGN KEY (type_id) REFERENCES public.animal_types(type_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: animal animal_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.animal
    ADD CONSTRAINT animal_ibfk_2 FOREIGN KEY (country_id) REFERENCES public.european_countries(country_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: daily_feeding daily_feeding_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.daily_feeding
    ADD CONSTRAINT daily_feeding_ibfk_1 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: daily_feeding daily_feeding_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.daily_feeding
    ADD CONSTRAINT daily_feeding_ibfk_2 FOREIGN KEY (feed_id) REFERENCES public.feed(feed_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: events events_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_ibfk_1 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: feed feed_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.feed
    ADD CONSTRAINT feed_ibfk_1 FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: weighing fk_weighing_op; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.weighing
    ADD CONSTRAINT fk_weighing_op FOREIGN KEY (operation_id) REFERENCES public.weighing_operations(operation_id) ON UPDATE RESTRICT ON DELETE SET NULL;

-- Name: health_records health_records_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.health_records
    ADD CONSTRAINT health_records_ibfk_1 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: health_records health_records_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.health_records
    ADD CONSTRAINT health_records_ibfk_2 FOREIGN KEY (item_id) REFERENCES public.medical_catalog(item_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: lot_animals lot_animals_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.lot_animals
    ADD CONSTRAINT lot_animals_ibfk_1 FOREIGN KEY (lot_id) REFERENCES public.lot(lot_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: lot_animals lot_animals_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.lot_animals
    ADD CONSTRAINT lot_animals_ibfk_2 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: medical_catalog medical_catalog_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.medical_catalog
    ADD CONSTRAINT medical_catalog_ibfk_1 FOREIGN KEY (supplier_id) REFERENCES public.suppliers(supplier_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: operational_costs operational_costs_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.operational_costs
    ADD CONSTRAINT operational_costs_ibfk_1 FOREIGN KEY (lot_id) REFERENCES public.lot(lot_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: operational_costs operational_costs_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.operational_costs
    ADD CONSTRAINT operational_costs_ibfk_2 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: sales sales_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_ibfk_1 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: sales sales_ibfk_2; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_ibfk_2 FOREIGN KEY (client_id) REFERENCES public.clients(client_id) ON UPDATE RESTRICT ON DELETE RESTRICT;

-- Name: weighing weighing_ibfk_1; Type: FK CONSTRAINT; Schema: public; Owner: -

ALTER TABLE ONLY public.weighing
    ADD CONSTRAINT weighing_ibfk_1 FOREIGN KEY (animal_id) REFERENCES public.animal(animal_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


-- =========================================================
-- Security for Supabase
-- Supabase also exposes the public schema through its REST API (anon /
-- authenticated roles). AgroFarm connects straight to Postgres and does not
-- use that API, so it is locked: RLS on every table with no policies, and no
-- privileges for the API roles. The app's own connection (table owner) is not
-- affected.
-- =========================================================
DO $$
DECLARE t record;
BEGIN
  FOR t IN SELECT tablename FROM pg_tables WHERE schemaname = 'public' LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t.tablename);
  END LOOP;
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'anon') THEN
    EXECUTE 'REVOKE ALL ON ALL TABLES IN SCHEMA public FROM anon, authenticated';
    EXECUTE 'REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM anon, authenticated';
  END IF;
END $$;
