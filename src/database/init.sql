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

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

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
    created timestamp without time zone DEFAULT now() NOT NULL
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
    to_device_id integer NOT NULL,
    data text,
    title text,
    body text,
    push_notification_type_id integer NOT NULL
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
    created timestamp without time zone DEFAULT now() NOT NULL
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
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);


--
-- Name: roles_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles_permissions ALTER COLUMN id SET DEFAULT nextval('public.user_permissions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: users_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_groups ALTER COLUMN id SET DEFAULT nextval('public.users_groups_id_seq'::regclass);


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.devices VALUES (3, '123456', 3, '2024-06-17 16:16:49.86759', '123');
INSERT INTO public.devices VALUES (4, '1234567', 4, '2024-06-17 16:17:00.150695', '1234');
INSERT INTO public.devices VALUES (5, '12345678', 3, '2024-06-17 16:19:20.905372', '12345');
INSERT INTO public.devices VALUES (6, '123456789', 5, '2024-06-17 16:20:17.652344', '123456');
INSERT INTO public.devices VALUES (7, 'b3dc4051-4014-443a-ab49-c036c843f5c0', 4, '2024-10-16 18:20:33.069338', NULL);


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.groups VALUES (2, 'test', 3, '2024-06-17 16:15:20.271736');
INSERT INTO public.groups VALUES (3, 'test2', 5, '2024-06-17 16:20:41.127677');
INSERT INTO public.groups VALUES (6, 'test3', 5, '2024-10-16 18:12:04.135854');
INSERT INTO public.groups VALUES (27, 'Security Squad', 4, '2024-10-16 19:01:13.053339');
INSERT INTO public.groups VALUES (31, 'Security Squad', 4, '2024-10-16 19:01:13.52197');
INSERT INTO public.groups VALUES (23, 'Security Squad', 4, '2024-10-16 19:01:12.613248');
INSERT INTO public.groups VALUES (16, 'Security Squad', 4, '2024-10-16 19:01:11.647119');
INSERT INTO public.groups VALUES (7, 'Security Squad', 4, '2024-10-16 18:20:53.025031');
INSERT INTO public.groups VALUES (26, 'Security Squad', 4, '2024-10-16 19:01:12.947519');
INSERT INTO public.groups VALUES (28, 'Security Squad', 4, '2024-10-16 19:01:13.174636');
INSERT INTO public.groups VALUES (30, 'Security Squad', 4, '2024-10-16 19:01:13.394754');
INSERT INTO public.groups VALUES (22, 'Security Squad', 4, '2024-10-16 19:01:12.501086');
INSERT INTO public.groups VALUES (18, 'Security Squad', 4, '2024-10-16 19:01:12.076425');
INSERT INTO public.groups VALUES (24, 'Security Squad', 4, '2024-10-16 19:01:12.727091');
INSERT INTO public.groups VALUES (19, 'Security Squad', 4, '2024-10-16 19:01:12.194022');
INSERT INTO public.groups VALUES (20, 'Security Squad', 4, '2024-10-16 19:01:12.290096');
INSERT INTO public.groups VALUES (21, 'Security Squad', 4, '2024-10-16 19:01:12.39343');
INSERT INTO public.groups VALUES (9, 'Security Squad', 4, '2024-10-16 18:21:19.271867');
INSERT INTO public.groups VALUES (29, 'Security Squad', 4, '2024-10-16 19:01:13.306455');
INSERT INTO public.groups VALUES (25, 'Security Squad', 4, '2024-10-16 19:01:12.840241');
INSERT INTO public.groups VALUES (32, 'Security Squad', 4, '2024-10-16 19:03:37.269042');
INSERT INTO public.groups VALUES (17, 'Security Squad', 4, '2024-10-16 19:01:11.806154');
INSERT INTO public.groups VALUES (8, 'Security Squad', 4, '2024-10-16 18:20:59.50976');
INSERT INTO public.groups VALUES (11, 'Security Squad', 4, '2024-10-16 18:21:19.552851');
INSERT INTO public.groups VALUES (10, 'Security Squad', 4, '2024-10-16 18:21:19.351003');
INSERT INTO public.groups VALUES (13, 'Security Squad', 4, '2024-10-16 18:50:55.163291');
INSERT INTO public.groups VALUES (12, 'Security Squad', 4, '2024-10-16 18:50:54.253743');
INSERT INTO public.groups VALUES (14, 'Security Squad', 4, '2024-10-16 18:50:56.429812');
INSERT INTO public.groups VALUES (15, 'Security Squad', 4, '2024-10-16 19:01:11.41791');
INSERT INTO public.groups VALUES (33, 'Maks Gay Squad', 4, '2024-10-16 19:46:17.506823');
INSERT INTO public.groups VALUES (34, 'Maks Gay Squad', 4, '2024-10-16 19:46:17.836328');
INSERT INTO public.groups VALUES (35, 'Maks Gay Squad', 4, '2024-10-16 19:46:18.010642');
INSERT INTO public.groups VALUES (36, 'Maks Gay Squad', 4, '2024-10-16 19:46:18.183511');
INSERT INTO public.groups VALUES (37, 'Maks Gay Squad', 4, '2024-10-16 19:46:18.333761');
INSERT INTO public.groups VALUES (38, 'Maks Gay Squad', 4, '2024-10-16 19:46:18.46213');
INSERT INTO public.groups VALUES (39, 'Maks Gay Squad', 4, '2024-10-16 19:46:18.591003');
INSERT INTO public.groups VALUES (40, 'Maks is Gay Because he does not pay attention', 4, '2024-10-16 19:47:19.604145');
INSERT INTO public.groups VALUES (41, 'Maks is Gay Because he does not pay attention', 4, '2024-10-16 19:47:19.741378');
INSERT INTO public.groups VALUES (42, 'Maks is Gay Because he does not pay attention', 4, '2024-10-16 19:47:19.880947');
INSERT INTO public.groups VALUES (43, 'Maks is Gay Because he does not pay attention', 4, '2024-10-16 19:47:20.010415');
INSERT INTO public.groups VALUES (44, 'Maks is Gay Because he does not pay attention', 4, '2024-10-16 19:47:20.114654');
INSERT INTO public.groups VALUES (45, 'Maks is Gay Because he does not pay attention', 4, '2024-10-16 19:47:20.246363');
INSERT INTO public.groups VALUES (46, 'Maks is Gay Because he does not pay attention', 4, '2024-10-16 19:47:20.359664');
INSERT INTO public.groups VALUES (47, 'Maks is Gay Because he does not pay attention', 4, '2024-10-16 19:47:20.566635');
INSERT INTO public.groups VALUES (48, 'Maks is Gay Because he does not pay attention', 4, '2024-10-16 19:47:20.725409');


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.permissions VALUES (1, 'user', '2024-06-15');


--
-- Data for Name: push_notification_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.push_notification_jobs VALUES (1, 2, true, false, false, NULL, '2024-06-20 09:32:56.449973', '2024-06-20 08:54:09.589491', 0);
INSERT INTO public.push_notification_jobs VALUES (2, 2, true, false, false, NULL, '2024-10-16 17:46:00.168803', '2024-06-20 09:32:40.595614', 0);


--
-- Data for Name: push_notification_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.push_notification_type VALUES (1, 'emergency alert', 1200, 0, false);
INSERT INTO public.push_notification_type VALUES (2, 'wake device', 1200, 1, false);
INSERT INTO public.push_notification_type VALUES (3, 'checkin', 1200, 0, false);


--
-- Data for Name: push_notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.push_notifications VALUES (2, 3, '{"body":"test"}', 'test', 'test', 1);


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.roles VALUES (1, 'user');
INSERT INTO public.roles VALUES (2, 'group_admin');


--
-- Data for Name: roles_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.roles_permissions VALUES (1, 1, 1);
INSERT INTO public.roles_permissions VALUES (2, 2, 1);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (3, '9501185061080', 1, '011895', 'callan', '2024-06-17 16:15:04.961011');
INSERT INTO public.users VALUES (4, '9812055281082', 1, '011895', 'makaveli', '2024-06-17 16:15:49.615796');
INSERT INTO public.users VALUES (5, '9905205061080', 1, '011895', 'random', '2024-06-17 16:19:56.477872');


--
-- Data for Name: users_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users_groups VALUES (2, 3, 1, '2024-06-17 16:16:13.466136', 2);
INSERT INTO public.users_groups VALUES (2, 4, 1, '2024-06-17 16:16:22.703048', 3);
INSERT INTO public.users_groups VALUES (3, 5, 1, '2024-06-17 16:21:19.054075', 4);
INSERT INTO public.users_groups VALUES (6, 5, 2, '2024-10-16 18:12:04.135854', 6);
INSERT INTO public.users_groups VALUES (7, 3, 2, '2024-10-16 18:20:53.025031', 7);
INSERT INTO public.users_groups VALUES (8, 3, 2, '2024-10-16 18:20:59.50976', 8);
INSERT INTO public.users_groups VALUES (9, 3, 2, '2024-10-16 18:21:19.271867', 9);
INSERT INTO public.users_groups VALUES (26, 4, 2, '2024-10-16 19:01:12.947519', 26);
INSERT INTO public.users_groups VALUES (24, 4, 2, '2024-10-16 19:01:12.727091', 24);
INSERT INTO public.users_groups VALUES (30, 4, 2, '2024-10-16 19:01:13.394754', 30);
INSERT INTO public.users_groups VALUES (32, 4, 2, '2024-10-16 19:03:37.269042', 32);
INSERT INTO public.users_groups VALUES (28, 4, 2, '2024-10-16 19:01:13.174636', 28);
INSERT INTO public.users_groups VALUES (21, 4, 2, '2024-10-16 19:01:12.39343', 21);
INSERT INTO public.users_groups VALUES (15, 4, 2, '2024-10-16 19:01:11.41791', 15);
INSERT INTO public.users_groups VALUES (10, 4, 2, '2024-10-16 18:21:19.351003', 10);
INSERT INTO public.users_groups VALUES (14, 4, 2, '2024-10-16 18:50:56.429812', 14);
INSERT INTO public.users_groups VALUES (13, 4, 2, '2024-10-16 18:50:55.163291', 13);
INSERT INTO public.users_groups VALUES (31, 4, 2, '2024-10-16 19:01:13.52197', 31);
INSERT INTO public.users_groups VALUES (11, 4, 2, '2024-10-16 18:21:19.552851', 11);
INSERT INTO public.users_groups VALUES (19, 4, 2, '2024-10-16 19:01:12.194022', 19);
INSERT INTO public.users_groups VALUES (12, 4, 2, '2024-10-16 18:50:54.253743', 12);
INSERT INTO public.users_groups VALUES (25, 4, 2, '2024-10-16 19:01:12.840241', 25);
INSERT INTO public.users_groups VALUES (29, 4, 2, '2024-10-16 19:01:13.306455', 29);
INSERT INTO public.users_groups VALUES (22, 4, 2, '2024-10-16 19:01:12.501086', 22);
INSERT INTO public.users_groups VALUES (27, 4, 2, '2024-10-16 19:01:13.053339', 27);
INSERT INTO public.users_groups VALUES (20, 4, 2, '2024-10-16 19:01:12.290096', 20);
INSERT INTO public.users_groups VALUES (23, 4, 2, '2024-10-16 19:01:12.613248', 23);
INSERT INTO public.users_groups VALUES (16, 4, 2, '2024-10-16 19:01:11.647119', 16);
INSERT INTO public.users_groups VALUES (17, 4, 2, '2024-10-16 19:01:11.806154', 17);
INSERT INTO public.users_groups VALUES (18, 4, 2, '2024-10-16 19:01:12.076425', 18);
INSERT INTO public.users_groups VALUES (33, 4, 2, '2024-10-16 19:46:17.506823', 33);
INSERT INTO public.users_groups VALUES (34, 4, 2, '2024-10-16 19:46:17.836328', 34);
INSERT INTO public.users_groups VALUES (35, 4, 2, '2024-10-16 19:46:18.010642', 35);
INSERT INTO public.users_groups VALUES (36, 4, 2, '2024-10-16 19:46:18.183511', 36);
INSERT INTO public.users_groups VALUES (37, 4, 2, '2024-10-16 19:46:18.333761', 37);
INSERT INTO public.users_groups VALUES (38, 4, 2, '2024-10-16 19:46:18.46213', 38);
INSERT INTO public.users_groups VALUES (39, 4, 2, '2024-10-16 19:46:18.591003', 39);
INSERT INTO public.users_groups VALUES (40, 4, 2, '2024-10-16 19:47:19.604145', 40);
INSERT INTO public.users_groups VALUES (41, 4, 2, '2024-10-16 19:47:19.741378', 41);
INSERT INTO public.users_groups VALUES (42, 4, 2, '2024-10-16 19:47:19.880947', 42);
INSERT INTO public.users_groups VALUES (43, 4, 2, '2024-10-16 19:47:20.010415', 43);
INSERT INTO public.users_groups VALUES (44, 4, 2, '2024-10-16 19:47:20.114654', 44);
INSERT INTO public.users_groups VALUES (45, 4, 2, '2024-10-16 19:47:20.246363', 45);
INSERT INTO public.users_groups VALUES (46, 4, 2, '2024-10-16 19:47:20.359664', 46);
INSERT INTO public.users_groups VALUES (47, 4, 2, '2024-10-16 19:47:20.566635', 47);
INSERT INTO public.users_groups VALUES (48, 4, 2, '2024-10-16 19:47:20.725409', 48);


--
-- Name: devices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.devices_id_seq', 7, true);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groups_id_seq', 48, true);


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

SELECT pg_catalog.setval('public.push_notifications_id_seq', 2, true);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 2, true);


--
-- Name: user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_permissions_id_seq', 2, true);


--
-- Name: users_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_groups_id_seq', 48, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 5, true);


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
-- Name: devices_device_uuid_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX devices_device_uuid_uindex ON public.devices USING btree (device_uuid);


--
-- Name: roles_role_name_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX roles_role_name_uindex ON public.roles USING btree (role_name);


--
-- Name: users_id_number_uindex; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX users_id_number_uindex ON public.users USING btree (id_number);


--
-- Name: groups on_insert_create_user_groups_entry_for_admin; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER on_insert_create_user_groups_entry_for_admin AFTER INSERT ON public.groups FOR EACH ROW EXECUTE FUNCTION public.trigger_on_insert_create_user_groups_entry_for_admin();


--
-- Name: push_notification_jobs update_completed_at_trigger; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_completed_at_trigger BEFORE UPDATE ON public.push_notification_jobs FOR EACH ROW WHEN (((old.pending IS DISTINCT FROM new.pending) OR (old.completed IS DISTINCT FROM new.completed))) EXECUTE FUNCTION public.update_completed_at();


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
-- Name: push_notifications push_notifications_devices_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notifications
    ADD CONSTRAINT push_notifications_devices_id_fk FOREIGN KEY (to_device_id) REFERENCES public.devices(id);


--
-- Name: push_notifications push_notifications_push_notification_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.push_notifications
    ADD CONSTRAINT push_notifications_push_notification_type_id_fk FOREIGN KEY (push_notification_type_id) REFERENCES public.push_notification_type(id);


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

