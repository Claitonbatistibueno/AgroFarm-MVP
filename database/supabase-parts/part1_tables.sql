-- AgroFarm on Supabase — PART 1 of 8: tables (safe to run again: it removes any half-created objects first)

DROP VIEW IF EXISTS public.view_animal_profitability;
DROP TABLE IF EXISTS public.accounts_payable, public.animal, public.animal_types, public.clients, public.company, public.daily_feeding, public.european_countries, public.events, public.feed, public.financial_categories, public.health_records, public.login_attempts, public.lot, public.lot_animals, public.market_prices, public.medical_catalog, public.operational_costs, public.sales, public.suppliers, public.users, public.weighing, public.weighing_operations CASCADE;


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

