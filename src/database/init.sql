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
    recurring_alert_end_user_id integer,
    seen_by_id integer,
    responded_by_id integer
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
    user_id integer
);


ALTER TABLE public.responded_by OWNER TO postgres;

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
    alert_id integer
);


ALTER TABLE public.seen_by OWNER TO postgres;

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
-- Data for Name: alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.alerts VALUES (32, '2025-01-09 13:26:36.037013', '37.4220936|-122.083922', 5, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.alerts VALUES (32, '2025-01-09 13:33:09.861828', '37.4220936|-122.083922', 6, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.alerts VALUES (32, '2025-01-09 13:33:59.084405', '37.4220936|-122.083922', 7, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.alerts VALUES (32, '2025-01-09 13:33:59.663187', '37.4220936|-122.083922', 8, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.alerts VALUES (32, '2025-01-09 13:35:21.95903', '37.4220936|-122.083922', 9, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.alerts VALUES (32, '2025-01-09 13:37:01.447499', '37.4220936|-122.083922', 10, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.alerts VALUES (32, '2025-01-09 13:37:01.981712', '37.4220936|-122.083922', 11, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.alerts VALUES (32, '2025-01-09 13:39:41.760585', '37.4220936|-122.083922', 12, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
INSERT INTO public.alerts VALUES (30, '2025-01-01 13:41:41.573', '37.4220936|-122.083922', 4, 3, NULL, 1, NULL, NULL, NULL, NULL);
INSERT INTO public.alerts VALUES (32, '2025-01-09 14:24:37.790345', '37.4220936|-122.083922', 13, 3, NULL, 1, NULL, NULL, NULL, NULL);
INSERT INTO public.alerts VALUES (32, '2025-01-09 14:32:16.636866', '37.4220936|-122.083922', 14, 2, NULL, 1, NULL, NULL, NULL, NULL);


--
-- Data for Name: alerts_status; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.alerts_status VALUES (1, 'ongoing');
INSERT INTO public.alerts_status VALUES (2, 'resolved');
INSERT INTO public.alerts_status VALUES (3, 'cancelled');


--
-- Data for Name: alerts_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.alerts_type VALUES (1, 'emergency');
INSERT INTO public.alerts_type VALUES (2, 'recurring');


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.devices VALUES (6, '123456789', 5, '2024-06-17 16:20:17.652344', '123456');
INSERT INTO public.devices VALUES (8, 'c2b9c2f7-7297-47ee-ba95-8a96836f604f', 6, '2024-10-24 17:49:29.775043', NULL);
INSERT INTO public.devices VALUES (24, '326ca8b5-a402-42c9-9d04-e3850f2fb08c', 14, '2025-01-02 11:21:01.470276', NULL);
INSERT INTO public.devices VALUES (25, 'ec57ebe6-8168-4c1b-a3fb-5b38fa47a037', 14, '2025-01-02 11:23:33.129046', NULL);
INSERT INTO public.devices VALUES (26, '28e05d9c-ff62-4534-b38c-d22603085be1', 14, '2025-01-02 11:26:16.16419', NULL);
INSERT INTO public.devices VALUES (27, '73b08675-8b12-4762-89c4-271bfc33ef97', 14, '2025-01-02 11:27:48.336042', NULL);
INSERT INTO public.devices VALUES (28, 'f42e2617-aaad-486a-b7c9-a5dd431fb7ba', 14, '2025-01-02 11:29:00.405796', NULL);
INSERT INTO public.devices VALUES (29, '2d4ccee5-ab5a-4cf7-8924-0b8a1eea7ba6', 14, '2025-01-02 11:30:35.204627', NULL);
INSERT INTO public.devices VALUES (30, 'c1a09368-0a7f-46f0-a930-b89033f90a59', 14, '2025-01-02 11:31:27.213744', NULL);
INSERT INTO public.devices VALUES (31, '94a490c9-21a8-43d1-b0ac-b763f27ffba9', 14, '2025-01-04 14:48:45.50924', NULL);
INSERT INTO public.devices VALUES (32, '81c311cc-d836-4f44-91a9-3d0c717d6c67', 14, '2025-01-09 13:24:19.941176', NULL);


--
-- Data for Name: groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.groups VALUES (3, 'test2', 5, '2024-06-17 16:20:41.127677', NULL);
INSERT INTO public.groups VALUES (54, 'mak''s gay friends', 6, '2024-10-24 17:50:53.119149', 'XT6-YUJ-678');
INSERT INTO public.groups VALUES (6, 'test3', 5, '2024-10-16 18:12:04.135854', 'XT6-YUJ-688');
INSERT INTO public.groups VALUES (55, 'Poes Lovers Anonymous ', 14, '2025-01-03 10:57:21.967945', '2X2-MEN-GL1');
INSERT INTO public.groups VALUES (56, 'Lovers of thick woman', 14, '2025-01-03 11:43:44.205324', '53A-7X5-533');


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

INSERT INTO public.push_notifications VALUES (2, '{"body":"test"}', 'test', 'test', 1, NULL);
INSERT INTO public.push_notifications VALUES (6, NULL, 'Alert triggered', 'An alert was triggered by Callan at 2025-01-03 13:41:41.573084', 1, 4);
INSERT INTO public.push_notifications VALUES (7, NULL, 'Alert triggered', 'An alert was triggered by Callan at 2025-01-09 13:26:36.037013', 1, 5);
INSERT INTO public.push_notifications VALUES (8, NULL, 'Alert triggered', 'An alert was triggered by Callan at 2025-01-09 13:33:09.861828', 1, 6);
INSERT INTO public.push_notifications VALUES (9, NULL, 'Alert triggered', 'An alert was triggered by Callan at 2025-01-09 13:33:59.084405', 1, 7);
INSERT INTO public.push_notifications VALUES (10, NULL, 'Alert triggered', 'An alert was triggered by Callan at 2025-01-09 13:33:59.663187', 1, 8);
INSERT INTO public.push_notifications VALUES (11, NULL, 'Alert triggered', 'An alert was triggered by Callan at 2025-01-09 13:35:21.95903', 1, 9);
INSERT INTO public.push_notifications VALUES (12, NULL, 'Alert triggered', 'An alert was triggered by Callan at 2025-01-09 13:37:01.447499', 1, 10);
INSERT INTO public.push_notifications VALUES (13, NULL, 'Alert triggered', 'An alert was triggered by Callan at 2025-01-09 13:37:01.981712', 1, 11);
INSERT INTO public.push_notifications VALUES (14, NULL, 'Alert triggered', 'An alert was triggered by Callan at 2025-01-09 13:39:41.760585', 1, 12);
INSERT INTO public.push_notifications VALUES (15, NULL, 'Alert triggered', 'An alert was triggered by Callan at 2025-01-09 14:24:37.790345', 1, 13);
INSERT INTO public.push_notifications VALUES (16, NULL, 'Alert triggered', 'An alert was triggered by Callan at 2025-01-09 14:32:16.636866', 1, 14);


--
-- Data for Name: push_notifications_users_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: responded_by; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.roles VALUES (1, 'user');
INSERT INTO public.roles VALUES (2, 'group_admin');
INSERT INTO public.roles VALUES (3, 'group_pending');
INSERT INTO public.roles VALUES (4, 'group_user');


--
-- Data for Name: roles_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.roles_permissions VALUES (1, 1, 1);
INSERT INTO public.roles_permissions VALUES (2, 2, 1);
INSERT INTO public.roles_permissions VALUES (3, 3, 1);
INSERT INTO public.roles_permissions VALUES (4, 4, 1);


--
-- Data for Name: seen_by; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users VALUES (5, '9905205061080', 1, '011895', 'random', '2024-06-17 16:19:56.477872');
INSERT INTO public.users VALUES (6, '9812055281082', 1, '9808', 'gay boy', '2024-10-24 17:49:29.762936');
INSERT INTO public.users VALUES (14, '9501185061080', 1, '0118', 'Callan', '2025-01-02 11:21:01.467056');


--
-- Data for Name: users_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.users_groups VALUES (3, 5, 2, '2024-06-17 16:21:19.054075', 4);
INSERT INTO public.users_groups VALUES (6, 5, 4, '2024-10-16 18:12:04.135854', 6);
INSERT INTO public.users_groups VALUES (54, 6, 2, '2024-10-24 17:52:11.816624', 60);
INSERT INTO public.users_groups VALUES (55, 14, 2, '2025-01-03 10:57:21.967945', 64);
INSERT INTO public.users_groups VALUES (56, 14, 2, '2025-01-03 11:43:44.205324', 65);


--
-- Name: alerts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.alerts_id_seq', 14, true);


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

SELECT pg_catalog.setval('public.devices_id_seq', 32, true);


--
-- Name: groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.groups_id_seq', 56, true);


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

SELECT pg_catalog.setval('public.push_notifications_id_seq', 16, true);


--
-- Name: push_notifications_users_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.push_notifications_users_groups_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 4, true);


--
-- Name: user_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_permissions_id_seq', 4, true);


--
-- Name: users_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_groups_id_seq', 65, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 14, true);


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
    ADD CONSTRAINT alerts_users_id_fk FOREIGN KEY (recurring_alert_end_user_id) REFERENCES public.users(id);


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
    ADD CONSTRAINT push_notifications_alerts_id_fk FOREIGN KEY (alert_id) REFERENCES public.alerts(id);


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
    ADD CONSTRAINT responded_by_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


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
    ADD CONSTRAINT seen_by_users_id_fk FOREIGN KEY (user_id) REFERENCES public.users(id);


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

