--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 16.3 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: alert_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.alert_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO push_notifications (data, title, body, push_notification_type_id, alert_id)
    VALUES (
        NULL,
        'Alert triggered',
        'An alert was triggered by ' ||
        COALESCE((SELECT name FROM users
                  WHERE id = (SELECT user_id FROM devices
                              WHERE id = NEW.triggering_device_id)), 'Unknown User') ||
        ' at ' || COALESCE(NEW.time::TEXT, 'Unknown Time'),
        1,
        NEW.id
    );
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.alert_insert() OWNER TO postgres;

--
-- Name: create_user_groups_entry_for_admin(integer, integer); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.create_user_groups_entry_for_admin(IN _group_id integer, IN _user_id integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    _roles_permissions_id INT;
BEGIN
    SELECT id INTO _roles_permissions_id from roles_permissions
              WHERE roles_permissions.role_id = (
              SELECT id FROM roles WHERE role_name='group_admin'
                                   );

    INSERT INTO users_groups
        (group_id, user_id, roles_permissions_id)
    VALUES
        (_group_id, _user_id, _roles_permissions_id);

END;
$$;


ALTER PROCEDURE public.create_user_groups_entry_for_admin(IN _group_id integer, IN _user_id integer) OWNER TO postgres;

--
-- Name: push_notification_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.push_notification_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO push_notification_jobs (push_id, completed, pending, failed, retry_attempt)
    VALUES (NEW.id, false, true, false,  0 );

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.push_notification_insert() OWNER TO postgres;

--
-- Name: push_notification_job_insert(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.push_notification_job_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO push_notifications_users_groups (push_notification_jobs_id, users_groups_id)
    SELECT NEW.id, ug.id
    FROM users_groups ug
    JOIN devices d ON ug.user_id = d.user_id
    JOIN alerts a ON d.id = a.triggering_device_id
    JOIN push_notifications pn ON a.id = pn.alert_id
    WHERE pn.id = NEW.push_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.push_notification_job_insert() OWNER TO postgres;

--
-- Name: trigger_on_insert_create_user_groups_entry_for_admin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trigger_on_insert_create_user_groups_entry_for_admin() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Call the stored procedure with some parameters
    CALL create_user_groups_entry_for_admin(NEW.id, NEW.created_by_user_id);

    RETURN NEW;  -- For `AFTER` triggers, you must return `NEW` or `OLD`
END $$;


ALTER FUNCTION public.trigger_on_insert_create_user_groups_entry_for_admin() OWNER TO postgres;

--
-- Name: update_completed_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_completed_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if the update sets pending to false and complete to true
    IF NEW.pending = false AND NEW.completed = true THEN
        -- Update completed_at with current timestamp
        NEW.completed_at := NOW();
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_completed_at() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alerts (
    triggering_device_id integer,
    "time" timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    location text NOT NULL,
    id integer NOT NULL,
    status_id integer,
    message text,
    type_id integer,
    alert_scheduled_time text,
    recurring_alert_end_user_id integer
);


ALTER TABLE public.alerts OWNER TO postgres;

--
-- Name: alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.alerts_id_seq OWNER TO postgres;

--
-- Name: alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.alerts_id_seq OWNED BY public.alerts.id;


--
-- Name: alerts_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alerts_status (
    id integer NOT NULL,
    status text NOT NULL
);


ALTER TABLE public.alerts_status OWNER TO postgres;

--
-- Name: alerts_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.alerts_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.alerts_status_id_seq OWNER TO postgres;

--
-- Name: alerts_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.alerts_status_id_seq OWNED BY public.alerts_status.id;


--
-- Name: alerts_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.alerts_type (
    id integer NOT NULL,
    type text
);


ALTER TABLE public.alerts_type OWNER TO postgres;

--
-- Name: alerts_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.alerts_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.alerts_type_id_seq OWNER TO postgres;

--
-- Name: alerts_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.alerts_type_id_seq OWNED BY public.alerts_type.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devices (
    id integer NOT NULL,
    device_uuid text NOT NULL,
    user_id integer NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    push_token text
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.devices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.devices_id_seq OWNER TO postgres;

--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.devices_id_seq OWNED BY public.devices.id;


--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.groups (
    id integer NOT NULL,
    name text NOT NULL,
    created_by_user_id integer NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    identification_string text
);


ALTER TABLE public.groups OWNER TO postgres;

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.groups_id_seq OWNER TO postgres;

--
-- Name: groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.groups_id_seq OWNED BY public.groups.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.permissions (
    id integer NOT NULL,
    name text NOT NULL,
    created date DEFAULT now() NOT NULL
);


ALTER TABLE public.permissions OWNER TO postgres;

--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.permissions_id_seq OWNER TO postgres;

--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.permissions_id_seq OWNED BY public.permissions.id;


--
-- Name: push_notification_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.push_notification_jobs (
    id integer NOT NULL,
    push_id integer NOT NULL,
    completed boolean DEFAULT false,
    pending boolean DEFAULT true,
    failed boolean DEFAULT false,
    error text,
    completed_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT now(),
    retry_attempt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.push_notification_jobs OWNER TO postgres;

--
-- Name: push_notification_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.push_notification_jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.push_notification_jobs_id_seq OWNER TO postgres;

--
-- Name: push_notification_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.push_notification_jobs_id_seq OWNED BY public.push_notification_jobs.id;


--
-- Name: push_notification_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.push_notification_type (
    id integer NOT NULL,
    name text NOT NULL,
    ttl integer DEFAULT 0 NOT NULL,
    priority integer DEFAULT 1 NOT NULL,
    mutable_content boolean DEFAULT false NOT NULL
);


ALTER TABLE public.push_notification_type OWNER TO postgres;

--
-- Name: push_notification_type_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.push_notification_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.push_notification_type_id_seq OWNER TO postgres;

--
-- Name: push_notification_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.push_notification_type_id_seq OWNED BY public.push_notification_type.id;


--
-- Name: push_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.push_notifications (
    id integer NOT NULL,
    data text,
    title text,
    body text,
    push_notification_type_id integer NOT NULL,
    alert_id integer
);


ALTER TABLE public.push_notifications OWNER TO postgres;

--
-- Name: push_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.push_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.push_notifications_id_seq OWNER TO postgres;

--
-- Name: push_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.push_notifications_id_seq OWNED BY public.push_notifications.id;


--
-- Name: push_notifications_users_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.push_notifications_users_groups (
    id integer NOT NULL,
    push_notification_jobs_id integer NOT NULL,
    users_groups_id integer NOT NULL
);


ALTER TABLE public.push_notifications_users_groups OWNER TO postgres;

--
-- Name: push_notifications_users_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.push_notifications_users_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.push_notifications_users_groups_id_seq OWNER TO postgres;

--
-- Name: push_notifications_users_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.push_notifications_users_groups_id_seq OWNED BY public.push_notifications_users_groups.id;


--
-- Name: responded_by; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.responded_by (
    id integer NOT NULL,
    alert_id integer,
    user_id integer,
    "time" timestamp without time zone DEFAULT now()
);


ALTER TABLE public.responded_by OWNER TO postgres;

--
-- Name: responded_by_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.responded_by_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.responded_by_id_seq OWNER TO postgres;

--
-- Name: responded_by_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.responded_by_id_seq OWNED BY public.responded_by.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer NOT NULL,
    role_name text NOT NULL
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roles_id_seq OWNED BY public.roles.id;


--
-- Name: roles_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles_permissions (
    id integer NOT NULL,
    role_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.roles_permissions OWNER TO postgres;

--
-- Name: seen_by; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seen_by (
    id integer NOT NULL,
    user_id integer,
    alert_id integer,
    "time" timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.seen_by OWNER TO postgres;

--
-- Name: seen_by_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seen_by_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seen_by_id_seq OWNER TO postgres;

--
-- Name: seen_by_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seen_by_id_seq OWNED BY public.seen_by.id;


--
-- Name: user_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_permissions_id_seq OWNER TO postgres;

--
-- Name: user_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_permissions_id_seq OWNED BY public.roles_permissions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    id_number text NOT NULL,
    role_id integer DEFAULT 0 NOT NULL,
    pin text NOT NULL,
    name text NOT NULL,
    created timestamp without time zone DEFAULT now() NOT NULL,
    email text,
    phone_number text,
    address text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_groups (
    group_id integer NOT NULL,
    user_id integer,
    roles_permissions_id integer,
    created timestamp without time zone DEFAULT now(),
    id integer NOT NULL
);


ALTER TABLE public.users_groups OWNER TO postgres;

--
-- Name: users_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_groups_id_seq OWNER TO postgres;

--
-- Name: users_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_groups_id_seq OWNED BY public.users_groups.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: alerts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts ALTER COLUMN id SET DEFAULT nextval('public.alerts_id_seq'::regclass);


--
-- Name: alerts_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts_status ALTER COLUMN id SET DEFAULT nextval('public.alerts_status_id_seq'::regclass);


--
-- Name: alerts_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts_type ALTER COLUMN id SET DEFAULT nextval('public.alerts_type_id_seq'::regclass);


--
-- Name: devices id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices ALTER COLUMN id SET DEFAULT nextval('public.devices_id_seq'::regclass);


--
-- Name: groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups ALTER COLUMN id SET DEFAULT nextval('public.groups_id_seq'::regclass);


--
-- Name: permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);


--
-- Name: push_notification_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notification_jobs ALTER COLUMN id SET DEFAULT nextval('public.push_notification_jobs_id_seq'::regclass);


--
-- Name: push_notification_type id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notification_type ALTER COLUMN id SET DEFAULT nextval('public.push_notification_type_id_seq'::regclass);


--
-- Name: push_notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notifications ALTER COLUMN id SET DEFAULT nextval('public.push_notifications_id_seq'::regclass);


--
-- Name: push_notifications_users_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notifications_users_groups ALTER COLUMN id SET DEFAULT nextval('public.push_notifications_users_groups_id_seq'::regclass);


--
-- Name: responded_by id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.responded_by ALTER COLUMN id SET DEFAULT nextval('public.responded_by_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: roles_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_permissions ALTER COLUMN id SET DEFAULT nextval('public.user_permissions_id_seq'::regclass);


--
-- Name: seen_by id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seen_by ALTER COLUMN id SET DEFAULT nextval('public.seen_by_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_groups ALTER COLUMN id SET DEFAULT nextval('public.users_groups_id_seq'::regclass);


--
-- Data for Name: alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alerts (triggering_device_id, "time", location, id, status_id, message, type_id, alert_scheduled_time, recurring_alert_end_user_id) FROM stdin;
34	2025-03-09 11:35:06.914774	37.4219983|-122.084	16	2	\N	1	\N	15
50	2025-03-09 12:52:05.32085	-27.80133|30.1094383	45	2	\N	1	\N	15
47	2025-03-09 13:01:56.760257	-26.1392265|28.395892	46	2	\N	1	\N	17
47	2025-03-09 13:13:12.551629	-26.1392265|28.395892	47	2	\N	1	\N	17
47	2025-03-09 13:13:12.696398	-26.1392265|28.395892	48	2	\N	1	\N	17
47	2025-03-09 13:13:12.959304	-26.1392265|28.395892	49	2	\N	1	\N	17
47	2025-03-09 13:13:13.351787	-26.1392265|28.395892	50	2	\N	1	\N	17
47	2025-03-09 13:13:15.031545	-26.1392265|28.395892	51	2	\N	1	\N	17
52	2025-03-09 13:41:16.40131	-26.1392372|28.3958907	52	2	\N	1	\N	17
56	2025-03-10 13:01:41.93371	37.4219983|-122.084	53	3	\N	1	\N	15
50	2025-03-09 12:48:23.742479	-27.80133|30.1094383	44	2	\N	1	\N	15
33	2025-03-09 11:17:08.933782	37.4219983|-122.084	15	2	\N	1	\N	15
34	2025-03-09 11:35:15.613369	37.4219983|-122.084	17	2	\N	1	\N	15
43	2025-03-09 12:18:26.348137	-27.801425|30.1094983	31	1	\N	1	\N	15
43	2025-03-09 12:18:33.635305	-27.801425|30.1094983	32	2	\N	1	\N	15
45	2025-03-09 12:24:04.848297	-26.1392286|28.3958951	33	2	\N	1	\N	17
45	2025-03-09 12:24:32.676365	-26.1392267|28.3958927	35	2	\N	1	\N	17
45	2025-03-09 12:25:04.263202	-26.1392267|28.3958927	36	2	\N	1	\N	17
\.


--
-- Data for Name: alerts_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alerts_status (id, status) FROM stdin;
1	ongoing
2	resolved
3	cancelled
\.


--
-- Data for Name: alerts_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.alerts_type (id, type) FROM stdin;
1	emergency
2	recurring
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.devices (id, device_uuid, user_id, created, push_token) FROM stdin;
33	100f67ad-c1a7-4c20-9803-05d8252fb623	15	2025-03-09 11:16:53.815093	\N
34	38fd3fff-9d8e-41cb-b835-e932443beadf	15	2025-03-09 11:34:36.044083	\N
43	e44b46c7-701a-4e2b-ac6d-9195208318a7	15	2025-03-09 12:18:07.498292	\N
44	3be1cdc3-8edd-4557-99f2-1866b1908098	17	2025-03-09 12:23:08.024088	\N
45	38651935-2058-4bf7-978d-701201bdcc96	17	2025-03-09 12:23:57.761894	\N
47	1b8c76f1-1160-42d0-963e-f4097ced20e9	17	2025-03-09 12:47:31.242258	\N
48	313f8817-79ce-40c0-aeb6-ae3b3154bd18	15	2025-03-09 12:47:32.958799	\N
49	5d7a8984-a530-40e5-9b0e-871b941cc800	17	2025-03-09 12:47:36.257694	\N
50	1fc5f10c-c803-466d-b424-8c128e709b21	15	2025-03-09 12:48:19.929045	\N
51	a121a945-4e38-4e5c-a278-b976db58f28e	18	2025-03-09 12:58:42.844681	\N
52	fd96b8fc-b21e-4684-812f-06475279e51a	17	2025-03-09 13:41:06.854336	\N
53	ab90c472-c5d4-4620-91ed-81b47b2b3e5d	17	2025-03-09 13:41:08.332944	\N
54	8150dac2-f88e-496e-ad86-a301f10433cc	15	2025-03-10 08:57:45.520125	\N
55	7faef345-a0f7-4192-b4d6-9dabc3d021cc	15	2025-03-10 12:06:13.979015	\N
56	1a59b324-cbe0-4da1-b44c-6df7c755c2b7	15	2025-03-10 13:01:32.393399	\N
57	26ff1ec4-9f05-4543-875b-b1a4ad01d302	15	2025-03-10 13:21:27.084835	\N
58	2dd756c8-734b-4e1d-b60e-09c3cba2f3e5	15	2025-03-11 07:44:49.23991	\N
59	dd9a57fe-f5c0-4663-99bc-e8b0719024e8	15	2025-03-11 08:40:02.475439	\N
60	e4e0468b-16d7-4e26-9259-feb5f9e20c24	15	2025-03-11 08:42:56.25561	\N
61	28698179-96d3-4081-838f-c37ab4471377	15	2025-03-11 12:05:53.18846	\N
62	1b8c1c41-93fe-4b6a-989e-bf8b94a1a6d3	15	2025-03-11 12:08:16.333947	\N
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, name, created_by_user_id, created, identification_string) FROM stdin;
57	Tesla	15	2025-03-09 11:17:32.100158	BH7-3NX-K74
59	Brian	17	2025-03-09 12:24:25.72473	W7Q-00F-877
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.permissions (id, name, created) FROM stdin;
1	user	2024-06-15
\.


--
-- Data for Name: push_notification_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.push_notification_jobs (id, push_id, completed, pending, failed, error, completed_at, created_at, retry_attempt) FROM stdin;
\.


--
-- Data for Name: push_notification_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.push_notification_type (id, name, ttl, priority, mutable_content) FROM stdin;
1	emergency alert	1200	0	f
2	wake device	1200	1	f
3	checkin	1200	0	f
\.


--
-- Data for Name: push_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.push_notifications (id, data, title, body, push_notification_type_id, alert_id) FROM stdin;
48	\N	Alert triggered	An alert was triggered by Brian at 2025-03-09 13:01:56.760257	1	46
49	\N	Alert triggered	An alert was triggered by Brian at 2025-03-09 13:13:12.551629	1	47
50	\N	Alert triggered	An alert was triggered by Brian at 2025-03-09 13:13:12.696398	1	48
51	\N	Alert triggered	An alert was triggered by Brian at 2025-03-09 13:13:12.959304	1	49
52	\N	Alert triggered	An alert was triggered by Brian at 2025-03-09 13:13:13.351787	1	50
53	\N	Alert triggered	An alert was triggered by Brian at 2025-03-09 13:13:15.031545	1	51
54	\N	Alert triggered	An alert was triggered by Brian at 2025-03-09 13:41:16.40131	1	52
55	\N	Alert triggered	An alert was triggered by Elon Musk at 2025-03-10 13:01:41.93371	1	53
17	\N	Alert triggered	An alert was triggered by Elon Musk at 2025-03-09 11:17:08.933782	1	15
18	\N	Alert triggered	An alert was triggered by Elon Musk at 2025-03-09 11:35:06.914774	1	16
19	\N	Alert triggered	An alert was triggered by Elon Musk at 2025-03-09 11:35:15.613369	1	17
33	\N	Alert triggered	An alert was triggered by Elon Musk at 2025-03-09 12:18:26.348137	1	31
34	\N	Alert triggered	An alert was triggered by Elon Musk at 2025-03-09 12:18:33.635305	1	32
35	\N	Alert triggered	An alert was triggered by Brian at 2025-03-09 12:24:04.848297	1	33
37	\N	Alert triggered	An alert was triggered by Brian at 2025-03-09 12:24:32.676365	1	35
38	\N	Alert triggered	An alert was triggered by Brian at 2025-03-09 12:25:04.263202	1	36
46	\N	Alert triggered	An alert was triggered by Elon Musk at 2025-03-09 12:48:23.742479	1	44
47	\N	Alert triggered	An alert was triggered by Elon Musk at 2025-03-09 12:52:05.32085	1	45
\.


--
-- Data for Name: push_notifications_users_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.push_notifications_users_groups (id, push_notification_jobs_id, users_groups_id) FROM stdin;
\.


--
-- Data for Name: responded_by; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.responded_by (id, alert_id, user_id, "time") FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, role_name) FROM stdin;
1	user
2	group_admin
3	group_pending
4	group_user
\.


--
-- Data for Name: roles_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles_permissions (id, role_id, permission_id) FROM stdin;
1	1	1
2	2	1
3	3	1
4	4	1
\.


--
-- Data for Name: seen_by; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.seen_by (id, user_id, alert_id, "time") FROM stdin;
1	15	15	2025-03-09 11:20:30.375297
2	15	16	2025-03-09 11:35:23.097129
3	15	17	2025-03-09 11:35:28.047805
5	17	33	2025-03-09 12:32:10.557409
6	17	35	2025-03-09 12:32:39.531638
8	15	32	2025-03-09 12:38:21.952029
9	17	46	2025-03-09 13:41:24.864868
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, id_number, role_id, pin, name, created, email, phone_number, address) FROM stdin;
15	9812055281082	1	9808	Elon Musk	2025-03-09 11:16:53.798522	\N	\N	\N
17	7203065001086	1	1972	Brian	2025-03-09 12:23:08.018277	\N	\N	\N
18	9501185061080	1	0118	Callan	2025-03-09 12:58:42.841783	\N	\N	\N
\.


--
-- Data for Name: users_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_groups (group_id, user_id, roles_permissions_id, created, id) FROM stdin;
57	15	2	2025-03-09 11:17:32.100158	66
59	17	2	2025-03-09 12:24:25.72473	68
59	18	4	2025-03-09 12:59:43.329746	71
\.


--
-- Name: alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alerts_id_seq', 53, true);


--
-- Name: alerts_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alerts_status_id_seq', 3, true);


--
-- Name: alerts_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alerts_type_id_seq', 2, true);


--
-- Name: devices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.devices_id_seq', 62, true);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groups_id_seq', 60, true);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permissions_id_seq', 1, true);


--
-- Name: push_notification_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.push_notification_jobs_id_seq', 2, true);


--
-- Name: push_notification_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.push_notification_type_id_seq', 3, true);


--
-- Name: push_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.push_notifications_id_seq', 55, true);


--
-- Name: push_notifications_users_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.push_notifications_users_groups_id_seq', 1, false);


--
-- Name: responded_by_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.responded_by_id_seq', 3, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 4, true);


--
-- Name: seen_by_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seen_by_id_seq', 10, true);


--
-- Name: user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_permissions_id_seq', 4, true);


--
-- Name: users_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_groups_id_seq', 71, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 18, true);


--
-- Name: alerts alerts_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_pk PRIMARY KEY (id);


--
-- Name: alerts_status alerts_status_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts_status
    ADD CONSTRAINT alerts_status_pk PRIMARY KEY (id);


--
-- Name: alerts_type alerts_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts_type
    ADD CONSTRAINT alerts_type_pk PRIMARY KEY (id);


--
-- Name: devices devices_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pk PRIMARY KEY (id);


--
-- Name: groups groups_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_pk PRIMARY KEY (id);


--
-- Name: permissions permissions_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pk PRIMARY KEY (id);


--
-- Name: push_notification_jobs push_notification_jobs_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notification_jobs
    ADD CONSTRAINT push_notification_jobs_pk PRIMARY KEY (id);


--
-- Name: push_notification_type push_notification_type_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notification_type
    ADD CONSTRAINT push_notification_type_pk PRIMARY KEY (id);


--
-- Name: push_notifications push_notifications_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notifications
    ADD CONSTRAINT push_notifications_pk PRIMARY KEY (id);


--
-- Name: push_notifications_users_groups push_notifications_users_groups_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notifications_users_groups
    ADD CONSTRAINT push_notifications_users_groups_pk PRIMARY KEY (id);


--
-- Name: responded_by responded_by_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.responded_by
    ADD CONSTRAINT responded_by_pk PRIMARY KEY (id);


--
-- Name: roles_permissions roles_permissions_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_permissions
    ADD CONSTRAINT roles_permissions_pk PRIMARY KEY (id);


--
-- Name: roles roles_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pk PRIMARY KEY (id);


--
-- Name: seen_by seen_by_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seen_by
    ADD CONSTRAINT seen_by_pk PRIMARY KEY (id);


--
-- Name: responded_by unique_alert_user_responded; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.responded_by
    ADD CONSTRAINT unique_alert_user_responded UNIQUE (alert_id, user_id);


--
-- Name: seen_by unique_alert_user_seen; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seen_by
    ADD CONSTRAINT unique_alert_user_seen UNIQUE (alert_id, user_id);


--
-- Name: users_groups users_groups_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_groups
    ADD CONSTRAINT users_groups_pk PRIMARY KEY (id);


--
-- Name: users users_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pk PRIMARY KEY (id);


--
-- Name: users users_pk_2; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pk_2 UNIQUE (email);


--
-- Name: users users_pk_3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pk_3 UNIQUE (phone_number);


--
-- Name: devices_device_uuid_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX devices_device_uuid_uindex ON public.devices USING btree (device_uuid);


--
-- Name: groups_identification_string_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX groups_identification_string_uindex ON public.groups USING btree (identification_string);


--
-- Name: roles_role_name_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX roles_role_name_uindex ON public.roles USING btree (role_name);


--
-- Name: users_id_number_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_id_number_uindex ON public.users USING btree (id_number);


--
-- Name: alerts after_insert_on_alert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_insert_on_alert AFTER INSERT ON public.alerts FOR EACH ROW EXECUTE FUNCTION public.alert_insert();


--
-- Name: push_notification_jobs after_push_notification_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_push_notification_insert AFTER INSERT ON public.push_notification_jobs FOR EACH ROW EXECUTE FUNCTION public.push_notification_insert();


--
-- Name: push_notification_jobs after_push_notification_job_insert; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER after_push_notification_job_insert AFTER INSERT ON public.push_notification_jobs FOR EACH ROW EXECUTE FUNCTION public.push_notification_job_insert();


--
-- Name: groups on_insert_create_user_groups_entry_for_admin; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER on_insert_create_user_groups_entry_for_admin AFTER INSERT ON public.groups FOR EACH ROW EXECUTE FUNCTION public.trigger_on_insert_create_user_groups_entry_for_admin();


--
-- Name: push_notification_jobs update_completed_at_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_completed_at_trigger BEFORE UPDATE ON public.push_notification_jobs FOR EACH ROW WHEN (((old.pending IS DISTINCT FROM new.pending) OR (old.completed IS DISTINCT FROM new.completed))) EXECUTE FUNCTION public.update_completed_at();


--
-- Name: alerts alerts_devices_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_devices_id_fk FOREIGN KEY (triggering_device_id) REFERENCES public.devices(id) ON DELETE CASCADE;


--
-- Name: alerts alerts_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.alerts
    ADD CONSTRAINT alerts_users_id_fk FOREIGN KEY (recurring_alert_end_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: devices devices_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: groups groups_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.groups
    ADD CONSTRAINT groups_users_id_fk FOREIGN KEY (created_by_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: push_notification_jobs push_notification_jobs_push_notifications_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notification_jobs
    ADD CONSTRAINT push_notification_jobs_push_notifications_id_fk FOREIGN KEY (push_id) REFERENCES public.push_notifications(id);


--
-- Name: push_notifications push_notifications_alerts_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notifications
    ADD CONSTRAINT push_notifications_alerts_id_fk FOREIGN KEY (alert_id) REFERENCES public.alerts(id) ON DELETE CASCADE;


--
-- Name: push_notifications push_notifications_push_notification_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notifications
    ADD CONSTRAINT push_notifications_push_notification_type_id_fk FOREIGN KEY (push_notification_type_id) REFERENCES public.push_notification_type(id);


--
-- Name: push_notifications_users_groups push_notifications_users_groups_push_notification_jobs_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notifications_users_groups
    ADD CONSTRAINT push_notifications_users_groups_push_notification_jobs_id_fk FOREIGN KEY (push_notification_jobs_id) REFERENCES public.push_notification_jobs(id);


--
-- Name: push_notifications_users_groups push_notifications_users_groups_users_groups_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notifications_users_groups
    ADD CONSTRAINT push_notifications_users_groups_users_groups_id_fk FOREIGN KEY (users_groups_id) REFERENCES public.users_groups(id);


--
-- Name: responded_by responded_by_alerts_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.responded_by
    ADD CONSTRAINT responded_by_alerts_id_fk FOREIGN KEY (alert_id) REFERENCES public.alerts(id);


--
-- Name: responded_by responded_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.responded_by
    ADD CONSTRAINT responded_by_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: roles_permissions roles_permissions_permissions_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_permissions
    ADD CONSTRAINT roles_permissions_permissions_id_fk FOREIGN KEY (permission_id) REFERENCES public.permissions(id);


--
-- Name: roles_permissions roles_permissions_roles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_permissions
    ADD CONSTRAINT roles_permissions_roles_id_fk FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: seen_by seen_by_alerts_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seen_by
    ADD CONSTRAINT seen_by_alerts_id_fk FOREIGN KEY (alert_id) REFERENCES public.alerts(id);


--
-- Name: seen_by seen_by_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seen_by
    ADD CONSTRAINT seen_by_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users_groups users_groups_groups_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_groups
    ADD CONSTRAINT users_groups_groups_id_fk FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: users_groups users_groups_users_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_groups
    ADD CONSTRAINT users_groups_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: users users_roles_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_roles_id_fk FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

