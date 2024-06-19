--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2 (Postgres.app)
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
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


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
    priority integer DEFAULT 1,
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
    body integer,
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
    user_group_permissions integer,
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
-- Name: users_groups_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users_groups_permissions (
    id integer NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);


ALTER TABLE public.users_groups_permissions OWNER TO postgres;

--
-- Name: users_groups_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_groups_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_groups_permissions_id_seq OWNER TO postgres;

--
-- Name: users_groups_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_groups_permissions_id_seq OWNED BY public.users_groups_permissions.id;


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
-- Name: users_groups_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_groups_permissions ALTER COLUMN id SET DEFAULT nextval('public.users_groups_permissions_id_seq'::regclass);


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.devices (id, device_uuid, user_id, created, push_token) FROM stdin;
3	123456	3	2024-06-17 16:16:49.86759	123
4	1234567	4	2024-06-17 16:17:00.150695	1234
5	12345678	3	2024-06-17 16:19:20.905372	12345
6	123456789	5	2024-06-17 16:20:17.652344	123456
\.


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.groups (id, name, created_by_user_id, created) FROM stdin;
2	test	3	2024-06-17 16:15:20.271736
3	test2	5	2024-06-17 16:20:41.127677
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

COPY public.push_notification_jobs (id, push_id, priority, completed, pending, failed, error, completed_at, created_at, retry_attempt) FROM stdin;
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

COPY public.push_notifications (id, to_device_id, data, title, body, push_notification_type_id) FROM stdin;
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles (id, role_name) FROM stdin;
1	user
\.


--
-- Data for Name: roles_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.roles_permissions (id, role_id, permission_id) FROM stdin;
1	1	1
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, id_number, role_id, pin, name, created) FROM stdin;
3	9501185061080	1	011895	callan	2024-06-17 16:15:04.961011
4	9812055281082	1	011895	makaveli	2024-06-17 16:15:49.615796
5	9905205061080	1	011895	random	2024-06-17 16:19:56.477872
\.


--
-- Data for Name: users_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_groups (group_id, user_id, user_group_permissions, created, id) FROM stdin;
2	3	1	2024-06-17 16:16:13.466136	2
2	4	1	2024-06-17 16:16:22.703048	3
3	5	1	2024-06-17 16:21:19.054075	4
\.


--
-- Data for Name: users_groups_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users_groups_permissions (id, user_id, group_id, permission_id) FROM stdin;
\.


--
-- Name: devices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.devices_id_seq', 6, true);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groups_id_seq', 3, true);


--
-- Name: permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.permissions_id_seq', 1, true);


--
-- Name: push_notification_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.push_notification_jobs_id_seq', 1, false);


--
-- Name: push_notification_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.push_notification_type_id_seq', 3, true);


--
-- Name: push_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.push_notifications_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 1, true);


--
-- Name: user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_permissions_id_seq', 1, true);


--
-- Name: users_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_groups_id_seq', 4, true);


--
-- Name: users_groups_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_groups_permissions_id_seq', 1, true);


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
-- Name: users_groups_permissions users_groups_permissions_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_groups_permissions
    ADD CONSTRAINT users_groups_permissions_pk PRIMARY KEY (id);


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
-- Name: users_groups_permissions users_groups_permissions_groups_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_groups_permissions
    ADD CONSTRAINT users_groups_permissions_groups_id_fk FOREIGN KEY (group_id) REFERENCES public.groups(id) ON DELETE CASCADE;


--
-- Name: users_groups_permissions users_groups_permissions_permissions_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users_groups_permissions
    ADD CONSTRAINT users_groups_permissions_permissions_id_fk FOREIGN KEY (permission_id) REFERENCES public.permissions(id);


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
-- PostgreSQL database dump complete
--

