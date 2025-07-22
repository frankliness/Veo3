--
-- PostgreSQL database dump
--

-- Dumped from database version 13.21 (Debian 13.21-1.pgdg120+1)
-- Dumped by pg_dump version 13.21 (Debian 13.21-1.pgdg120+1)

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
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: airflow
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN
            NEW.updated_at = CURRENT_TIMESTAMP;
            RETURN NEW;
        END;
        $$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO airflow;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ab_permission; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.ab_permission (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE public.ab_permission OWNER TO airflow;

--
-- Name: ab_permission_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.ab_permission_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_permission_id_seq OWNER TO airflow;

--
-- Name: ab_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.ab_permission_id_seq OWNED BY public.ab_permission.id;


--
-- Name: ab_permission_view; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.ab_permission_view (
    id integer NOT NULL,
    permission_id integer,
    view_menu_id integer
);


ALTER TABLE public.ab_permission_view OWNER TO airflow;

--
-- Name: ab_permission_view_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.ab_permission_view_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_permission_view_id_seq OWNER TO airflow;

--
-- Name: ab_permission_view_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.ab_permission_view_id_seq OWNED BY public.ab_permission_view.id;


--
-- Name: ab_permission_view_role; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.ab_permission_view_role (
    id integer NOT NULL,
    permission_view_id integer,
    role_id integer
);


ALTER TABLE public.ab_permission_view_role OWNER TO airflow;

--
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.ab_permission_view_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_permission_view_role_id_seq OWNER TO airflow;

--
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.ab_permission_view_role_id_seq OWNED BY public.ab_permission_view_role.id;


--
-- Name: ab_register_user; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.ab_register_user (
    id integer NOT NULL,
    first_name character varying(256) NOT NULL,
    last_name character varying(256) NOT NULL,
    username character varying(512) NOT NULL,
    password character varying(256),
    email character varying(512) NOT NULL,
    registration_date timestamp without time zone,
    registration_hash character varying(256)
);


ALTER TABLE public.ab_register_user OWNER TO airflow;

--
-- Name: ab_register_user_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.ab_register_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_register_user_id_seq OWNER TO airflow;

--
-- Name: ab_register_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.ab_register_user_id_seq OWNED BY public.ab_register_user.id;


--
-- Name: ab_role; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.ab_role (
    id integer NOT NULL,
    name character varying(64) NOT NULL
);


ALTER TABLE public.ab_role OWNER TO airflow;

--
-- Name: ab_role_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.ab_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_role_id_seq OWNER TO airflow;

--
-- Name: ab_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.ab_role_id_seq OWNED BY public.ab_role.id;


--
-- Name: ab_user; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.ab_user (
    id integer NOT NULL,
    first_name character varying(256) NOT NULL,
    last_name character varying(256) NOT NULL,
    username character varying(512) NOT NULL,
    password character varying(256),
    active boolean,
    email character varying(512) NOT NULL,
    last_login timestamp without time zone,
    login_count integer,
    fail_login_count integer,
    created_on timestamp without time zone,
    changed_on timestamp without time zone,
    created_by_fk integer,
    changed_by_fk integer
);


ALTER TABLE public.ab_user OWNER TO airflow;

--
-- Name: ab_user_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.ab_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_user_id_seq OWNER TO airflow;

--
-- Name: ab_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.ab_user_id_seq OWNED BY public.ab_user.id;


--
-- Name: ab_user_role; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.ab_user_role (
    id integer NOT NULL,
    user_id integer,
    role_id integer
);


ALTER TABLE public.ab_user_role OWNER TO airflow;

--
-- Name: ab_user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.ab_user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_user_role_id_seq OWNER TO airflow;

--
-- Name: ab_user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.ab_user_role_id_seq OWNED BY public.ab_user_role.id;


--
-- Name: ab_view_menu; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.ab_view_menu (
    id integer NOT NULL,
    name character varying(250) NOT NULL
);


ALTER TABLE public.ab_view_menu OWNER TO airflow;

--
-- Name: ab_view_menu_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.ab_view_menu_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ab_view_menu_id_seq OWNER TO airflow;

--
-- Name: ab_view_menu_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.ab_view_menu_id_seq OWNED BY public.ab_view_menu.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO airflow;

--
-- Name: callback_request; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.callback_request (
    id integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    priority_weight integer NOT NULL,
    callback_data json NOT NULL,
    callback_type character varying(20) NOT NULL,
    processor_subdir character varying(2000)
);


ALTER TABLE public.callback_request OWNER TO airflow;

--
-- Name: callback_request_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.callback_request_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.callback_request_id_seq OWNER TO airflow;

--
-- Name: callback_request_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.callback_request_id_seq OWNED BY public.callback_request.id;


--
-- Name: connection; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.connection (
    id integer NOT NULL,
    conn_id character varying(250) NOT NULL,
    conn_type character varying(500) NOT NULL,
    description text,
    host character varying(500),
    schema character varying(500),
    login text,
    password text,
    port integer,
    is_encrypted boolean,
    is_extra_encrypted boolean,
    extra text
);


ALTER TABLE public.connection OWNER TO airflow;

--
-- Name: connection_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.connection_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.connection_id_seq OWNER TO airflow;

--
-- Name: connection_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.connection_id_seq OWNED BY public.connection.id;


--
-- Name: dag; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dag (
    dag_id character varying(250) NOT NULL,
    root_dag_id character varying(250),
    is_paused boolean,
    is_subdag boolean,
    is_active boolean,
    last_parsed_time timestamp with time zone,
    last_pickled timestamp with time zone,
    last_expired timestamp with time zone,
    scheduler_lock boolean,
    pickle_id integer,
    fileloc character varying(2000),
    processor_subdir character varying(2000),
    owners character varying(2000),
    dag_display_name character varying(2000),
    description text,
    default_view character varying(25),
    schedule_interval text,
    timetable_description character varying(1000),
    dataset_expression json,
    max_active_tasks integer NOT NULL,
    max_active_runs integer,
    max_consecutive_failed_dag_runs integer NOT NULL,
    has_task_concurrency_limits boolean NOT NULL,
    has_import_errors boolean DEFAULT false,
    next_dagrun timestamp with time zone,
    next_dagrun_data_interval_start timestamp with time zone,
    next_dagrun_data_interval_end timestamp with time zone,
    next_dagrun_create_after timestamp with time zone
);


ALTER TABLE public.dag OWNER TO airflow;

--
-- Name: dag_code; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dag_code (
    fileloc_hash bigint NOT NULL,
    fileloc character varying(2000) NOT NULL,
    last_updated timestamp with time zone NOT NULL,
    source_code text NOT NULL
);


ALTER TABLE public.dag_code OWNER TO airflow;

--
-- Name: dag_owner_attributes; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dag_owner_attributes (
    dag_id character varying(250) NOT NULL,
    owner character varying(500) NOT NULL,
    link character varying(500) NOT NULL
);


ALTER TABLE public.dag_owner_attributes OWNER TO airflow;

--
-- Name: dag_pickle; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dag_pickle (
    id integer NOT NULL,
    pickle bytea,
    created_dttm timestamp with time zone,
    pickle_hash bigint
);


ALTER TABLE public.dag_pickle OWNER TO airflow;

--
-- Name: dag_pickle_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.dag_pickle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dag_pickle_id_seq OWNER TO airflow;

--
-- Name: dag_pickle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.dag_pickle_id_seq OWNED BY public.dag_pickle.id;


--
-- Name: dag_run; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dag_run (
    id integer NOT NULL,
    dag_id character varying(250) NOT NULL,
    queued_at timestamp with time zone,
    execution_date timestamp with time zone NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    state character varying(50),
    run_id character varying(250) NOT NULL,
    creating_job_id integer,
    external_trigger boolean,
    run_type character varying(50) NOT NULL,
    conf bytea,
    data_interval_start timestamp with time zone,
    data_interval_end timestamp with time zone,
    last_scheduling_decision timestamp with time zone,
    dag_hash character varying(32),
    log_template_id integer,
    updated_at timestamp with time zone,
    clear_number integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.dag_run OWNER TO airflow;

--
-- Name: dag_run_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.dag_run_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dag_run_id_seq OWNER TO airflow;

--
-- Name: dag_run_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.dag_run_id_seq OWNED BY public.dag_run.id;


--
-- Name: dag_run_note; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dag_run_note (
    user_id integer,
    dag_run_id integer NOT NULL,
    content character varying(1000),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.dag_run_note OWNER TO airflow;

--
-- Name: dag_schedule_dataset_reference; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dag_schedule_dataset_reference (
    dataset_id integer NOT NULL,
    dag_id character varying(250) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.dag_schedule_dataset_reference OWNER TO airflow;

--
-- Name: dag_tag; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dag_tag (
    name character varying(100) NOT NULL,
    dag_id character varying(250) NOT NULL
);


ALTER TABLE public.dag_tag OWNER TO airflow;

--
-- Name: dag_warning; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dag_warning (
    dag_id character varying(250) NOT NULL,
    warning_type character varying(50) NOT NULL,
    message text NOT NULL,
    "timestamp" timestamp with time zone NOT NULL
);


ALTER TABLE public.dag_warning OWNER TO airflow;

--
-- Name: dagrun_dataset_event; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dagrun_dataset_event (
    dag_run_id integer NOT NULL,
    event_id integer NOT NULL
);


ALTER TABLE public.dagrun_dataset_event OWNER TO airflow;

--
-- Name: dataset; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dataset (
    id integer NOT NULL,
    uri character varying(3000) NOT NULL,
    extra json NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    is_orphaned boolean DEFAULT false NOT NULL
);


ALTER TABLE public.dataset OWNER TO airflow;

--
-- Name: dataset_dag_run_queue; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dataset_dag_run_queue (
    dataset_id integer NOT NULL,
    target_dag_id character varying(250) NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.dataset_dag_run_queue OWNER TO airflow;

--
-- Name: dataset_event; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.dataset_event (
    id integer NOT NULL,
    dataset_id integer NOT NULL,
    extra json NOT NULL,
    source_task_id character varying(250),
    source_dag_id character varying(250),
    source_run_id character varying(250),
    source_map_index integer DEFAULT '-1'::integer,
    "timestamp" timestamp with time zone NOT NULL
);


ALTER TABLE public.dataset_event OWNER TO airflow;

--
-- Name: dataset_event_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.dataset_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dataset_event_id_seq OWNER TO airflow;

--
-- Name: dataset_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.dataset_event_id_seq OWNED BY public.dataset_event.id;


--
-- Name: dataset_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.dataset_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dataset_id_seq OWNER TO airflow;

--
-- Name: dataset_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.dataset_id_seq OWNED BY public.dataset.id;


--
-- Name: import_error; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.import_error (
    id integer NOT NULL,
    "timestamp" timestamp with time zone,
    filename character varying(1024),
    stacktrace text,
    processor_subdir character varying(2000)
);


ALTER TABLE public.import_error OWNER TO airflow;

--
-- Name: import_error_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.import_error_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.import_error_id_seq OWNER TO airflow;

--
-- Name: import_error_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.import_error_id_seq OWNED BY public.import_error.id;


--
-- Name: job; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.job (
    id integer NOT NULL,
    dag_id character varying(250),
    state character varying(20),
    job_type character varying(30),
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    latest_heartbeat timestamp with time zone,
    executor_class character varying(500),
    hostname character varying(500),
    unixname character varying(1000)
);


ALTER TABLE public.job OWNER TO airflow;

--
-- Name: job_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.job_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_id_seq OWNER TO airflow;

--
-- Name: job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.job_id_seq OWNED BY public.job.id;


--
-- Name: jobs; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.jobs (
    id integer NOT NULL,
    prompt_text text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    job_type text NOT NULL,
    local_path text,
    gcs_uri text,
    operation_id text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT jobs_job_type_check CHECK ((job_type = ANY (ARRAY['IMAGE_TEST'::text, 'VIDEO_PROD'::text]))),
    CONSTRAINT jobs_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'completed'::text, 'failed'::text, 'awaiting_retry'::text])))
);


ALTER TABLE public.jobs OWNER TO airflow;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.jobs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.jobs_id_seq OWNER TO airflow;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: log; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.log (
    id integer NOT NULL,
    dttm timestamp with time zone,
    dag_id character varying(250),
    task_id character varying(250),
    map_index integer,
    event character varying(60),
    execution_date timestamp with time zone,
    run_id character varying(250),
    owner character varying(500),
    owner_display_name character varying(500),
    extra text
);


ALTER TABLE public.log OWNER TO airflow;

--
-- Name: log_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_id_seq OWNER TO airflow;

--
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.log_id_seq OWNED BY public.log.id;


--
-- Name: log_template; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.log_template (
    id integer NOT NULL,
    filename text NOT NULL,
    elasticsearch_id text NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.log_template OWNER TO airflow;

--
-- Name: log_template_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.log_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.log_template_id_seq OWNER TO airflow;

--
-- Name: log_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.log_template_id_seq OWNED BY public.log_template.id;


--
-- Name: rendered_task_instance_fields; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.rendered_task_instance_fields (
    dag_id character varying(250) NOT NULL,
    task_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    rendered_fields json NOT NULL,
    k8s_pod_yaml json
);


ALTER TABLE public.rendered_task_instance_fields OWNER TO airflow;

--
-- Name: serialized_dag; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.serialized_dag (
    dag_id character varying(250) NOT NULL,
    fileloc character varying(2000) NOT NULL,
    fileloc_hash bigint NOT NULL,
    data json,
    data_compressed bytea,
    last_updated timestamp with time zone NOT NULL,
    dag_hash character varying(32) NOT NULL,
    processor_subdir character varying(2000)
);


ALTER TABLE public.serialized_dag OWNER TO airflow;

--
-- Name: session; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.session (
    id integer NOT NULL,
    session_id character varying(255),
    data bytea,
    expiry timestamp without time zone
);


ALTER TABLE public.session OWNER TO airflow;

--
-- Name: session_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.session_id_seq OWNER TO airflow;

--
-- Name: session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.session_id_seq OWNED BY public.session.id;


--
-- Name: sla_miss; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.sla_miss (
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    execution_date timestamp with time zone NOT NULL,
    email_sent boolean,
    "timestamp" timestamp with time zone,
    description text,
    notification_sent boolean
);


ALTER TABLE public.sla_miss OWNER TO airflow;

--
-- Name: slot_pool; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.slot_pool (
    id integer NOT NULL,
    pool character varying(256),
    slots integer,
    description text,
    include_deferred boolean NOT NULL
);


ALTER TABLE public.slot_pool OWNER TO airflow;

--
-- Name: slot_pool_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.slot_pool_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.slot_pool_id_seq OWNER TO airflow;

--
-- Name: slot_pool_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.slot_pool_id_seq OWNED BY public.slot_pool.id;


--
-- Name: task_fail; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.task_fail (
    id integer NOT NULL,
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    duration integer
);


ALTER TABLE public.task_fail OWNER TO airflow;

--
-- Name: task_fail_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.task_fail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.task_fail_id_seq OWNER TO airflow;

--
-- Name: task_fail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.task_fail_id_seq OWNED BY public.task_fail.id;


--
-- Name: task_instance; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.task_instance (
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    duration double precision,
    state character varying(20),
    try_number integer,
    max_tries integer DEFAULT '-1'::integer,
    hostname character varying(1000),
    unixname character varying(1000),
    job_id integer,
    pool character varying(256) NOT NULL,
    pool_slots integer NOT NULL,
    queue character varying(256),
    priority_weight integer,
    operator character varying(1000),
    custom_operator_name character varying(1000),
    queued_dttm timestamp with time zone,
    queued_by_job_id integer,
    pid integer,
    executor_config bytea,
    updated_at timestamp with time zone,
    rendered_map_index character varying(250),
    external_executor_id character varying(250),
    trigger_id integer,
    trigger_timeout timestamp without time zone,
    next_method character varying(1000),
    next_kwargs json,
    task_display_name character varying(2000)
);


ALTER TABLE public.task_instance OWNER TO airflow;

--
-- Name: task_instance_note; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.task_instance_note (
    user_id integer,
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer NOT NULL,
    content character varying(1000),
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.task_instance_note OWNER TO airflow;

--
-- Name: task_map; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.task_map (
    dag_id character varying(250) NOT NULL,
    task_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer NOT NULL,
    length integer NOT NULL,
    keys json,
    CONSTRAINT ck_task_map_task_map_length_not_negative CHECK ((length >= 0))
);


ALTER TABLE public.task_map OWNER TO airflow;

--
-- Name: task_outlet_dataset_reference; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.task_outlet_dataset_reference (
    dataset_id integer NOT NULL,
    dag_id character varying(250) NOT NULL,
    task_id character varying(250) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL
);


ALTER TABLE public.task_outlet_dataset_reference OWNER TO airflow;

--
-- Name: task_reschedule; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.task_reschedule (
    id integer NOT NULL,
    task_id character varying(250) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    try_number integer NOT NULL,
    start_date timestamp with time zone NOT NULL,
    end_date timestamp with time zone NOT NULL,
    duration integer NOT NULL,
    reschedule_date timestamp with time zone NOT NULL
);


ALTER TABLE public.task_reschedule OWNER TO airflow;

--
-- Name: task_reschedule_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.task_reschedule_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.task_reschedule_id_seq OWNER TO airflow;

--
-- Name: task_reschedule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.task_reschedule_id_seq OWNED BY public.task_reschedule.id;


--
-- Name: trigger; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.trigger (
    id integer NOT NULL,
    classpath character varying(1000) NOT NULL,
    kwargs text NOT NULL,
    created_date timestamp with time zone NOT NULL,
    triggerer_id integer
);


ALTER TABLE public.trigger OWNER TO airflow;

--
-- Name: trigger_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.trigger_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.trigger_id_seq OWNER TO airflow;

--
-- Name: trigger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.trigger_id_seq OWNED BY public.trigger.id;


--
-- Name: variable; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.variable (
    id integer NOT NULL,
    key character varying(250),
    val text,
    description text,
    is_encrypted boolean
);


ALTER TABLE public.variable OWNER TO airflow;

--
-- Name: variable_id_seq; Type: SEQUENCE; Schema: public; Owner: airflow
--

CREATE SEQUENCE public.variable_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.variable_id_seq OWNER TO airflow;

--
-- Name: variable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: airflow
--

ALTER SEQUENCE public.variable_id_seq OWNED BY public.variable.id;


--
-- Name: xcom; Type: TABLE; Schema: public; Owner: airflow
--

CREATE TABLE public.xcom (
    dag_run_id integer NOT NULL,
    task_id character varying(250) NOT NULL,
    map_index integer DEFAULT '-1'::integer NOT NULL,
    key character varying(512) NOT NULL,
    dag_id character varying(250) NOT NULL,
    run_id character varying(250) NOT NULL,
    value bytea,
    "timestamp" timestamp with time zone NOT NULL
);


ALTER TABLE public.xcom OWNER TO airflow;

--
-- Name: ab_permission id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission ALTER COLUMN id SET DEFAULT nextval('public.ab_permission_id_seq'::regclass);


--
-- Name: ab_permission_view id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission_view ALTER COLUMN id SET DEFAULT nextval('public.ab_permission_view_id_seq'::regclass);


--
-- Name: ab_permission_view_role id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission_view_role ALTER COLUMN id SET DEFAULT nextval('public.ab_permission_view_role_id_seq'::regclass);


--
-- Name: ab_register_user id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_register_user ALTER COLUMN id SET DEFAULT nextval('public.ab_register_user_id_seq'::regclass);


--
-- Name: ab_role id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_role ALTER COLUMN id SET DEFAULT nextval('public.ab_role_id_seq'::regclass);


--
-- Name: ab_user id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_user ALTER COLUMN id SET DEFAULT nextval('public.ab_user_id_seq'::regclass);


--
-- Name: ab_user_role id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_user_role ALTER COLUMN id SET DEFAULT nextval('public.ab_user_role_id_seq'::regclass);


--
-- Name: ab_view_menu id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_view_menu ALTER COLUMN id SET DEFAULT nextval('public.ab_view_menu_id_seq'::regclass);


--
-- Name: callback_request id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.callback_request ALTER COLUMN id SET DEFAULT nextval('public.callback_request_id_seq'::regclass);


--
-- Name: connection id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.connection ALTER COLUMN id SET DEFAULT nextval('public.connection_id_seq'::regclass);


--
-- Name: dag_pickle id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_pickle ALTER COLUMN id SET DEFAULT nextval('public.dag_pickle_id_seq'::regclass);


--
-- Name: dag_run id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_run ALTER COLUMN id SET DEFAULT nextval('public.dag_run_id_seq'::regclass);


--
-- Name: dataset id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dataset ALTER COLUMN id SET DEFAULT nextval('public.dataset_id_seq'::regclass);


--
-- Name: dataset_event id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dataset_event ALTER COLUMN id SET DEFAULT nextval('public.dataset_event_id_seq'::regclass);


--
-- Name: import_error id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.import_error ALTER COLUMN id SET DEFAULT nextval('public.import_error_id_seq'::regclass);


--
-- Name: job id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.job ALTER COLUMN id SET DEFAULT nextval('public.job_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: log id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq'::regclass);


--
-- Name: log_template id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.log_template ALTER COLUMN id SET DEFAULT nextval('public.log_template_id_seq'::regclass);


--
-- Name: session id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.session ALTER COLUMN id SET DEFAULT nextval('public.session_id_seq'::regclass);


--
-- Name: slot_pool id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.slot_pool ALTER COLUMN id SET DEFAULT nextval('public.slot_pool_id_seq'::regclass);


--
-- Name: task_fail id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_fail ALTER COLUMN id SET DEFAULT nextval('public.task_fail_id_seq'::regclass);


--
-- Name: task_reschedule id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_reschedule ALTER COLUMN id SET DEFAULT nextval('public.task_reschedule_id_seq'::regclass);


--
-- Name: trigger id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.trigger ALTER COLUMN id SET DEFAULT nextval('public.trigger_id_seq'::regclass);


--
-- Name: variable id; Type: DEFAULT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.variable ALTER COLUMN id SET DEFAULT nextval('public.variable_id_seq'::regclass);


--
-- Data for Name: ab_permission; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.ab_permission (id, name) FROM stdin;
1	can_edit
2	can_read
3	can_create
4	can_delete
5	menu_access
\.


--
-- Data for Name: ab_permission_view; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.ab_permission_view (id, permission_id, view_menu_id) FROM stdin;
1	1	4
2	2	4
3	1	5
4	2	5
5	1	6
6	2	6
7	3	8
8	2	8
9	1	8
10	4	8
11	5	9
12	5	10
13	3	11
14	2	11
15	1	11
16	4	11
17	5	12
18	2	13
19	5	14
20	2	15
21	5	16
22	2	17
23	5	18
24	2	19
25	5	20
26	3	23
27	2	23
28	1	23
29	4	23
30	5	23
31	5	24
32	2	25
33	5	25
34	2	26
35	5	26
36	3	27
37	2	27
38	1	27
39	4	27
40	5	27
41	5	28
42	3	29
43	2	29
44	1	29
45	4	29
46	5	29
47	2	30
48	5	30
49	2	31
50	5	31
51	2	32
52	5	32
53	3	33
54	2	33
55	1	33
56	4	33
57	5	33
58	2	34
59	5	34
60	4	34
61	1	34
62	2	35
63	5	35
64	2	36
65	5	36
66	3	37
67	2	37
68	1	37
69	4	37
70	5	37
71	2	38
72	4	38
73	5	38
74	5	40
75	5	44
76	5	45
77	5	46
78	5	47
79	5	48
80	4	49
81	1	49
82	2	49
83	4	50
84	1	50
85	2	50
86	4	44
87	2	44
88	1	44
89	2	40
90	2	51
91	2	46
92	2	45
93	2	52
94	2	53
95	2	54
96	2	55
97	3	46
98	4	46
99	4	56
100	1	56
101	2	56
102	4	57
103	1	57
104	2	57
\.


--
-- Data for Name: ab_permission_view_role; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.ab_permission_view_role (id, permission_view_id, role_id) FROM stdin;
1	1	1
2	2	1
3	3	1
4	4	1
5	5	1
6	6	1
7	7	1
8	8	1
9	9	1
10	10	1
11	11	1
12	12	1
13	13	1
14	14	1
15	15	1
16	16	1
17	17	1
18	18	1
19	19	1
20	20	1
21	21	1
22	22	1
23	23	1
24	24	1
25	25	1
26	26	1
27	27	1
28	28	1
29	29	1
30	30	1
31	31	1
32	32	1
33	33	1
34	34	1
35	35	1
36	36	1
37	37	1
38	38	1
39	39	1
40	40	1
41	41	1
42	42	1
43	43	1
44	44	1
45	45	1
46	46	1
47	47	1
48	48	1
49	49	1
50	50	1
51	51	1
52	52	1
53	53	1
54	54	1
55	55	1
56	56	1
57	57	1
58	58	1
59	59	1
60	60	1
61	61	1
62	62	1
63	63	1
64	64	1
65	65	1
66	66	1
67	67	1
68	68	1
69	69	1
70	70	1
71	71	1
72	72	1
73	73	1
74	74	1
75	75	1
76	76	1
77	77	1
78	78	1
79	79	1
80	87	3
81	89	3
82	90	3
83	27	3
84	91	3
85	92	3
86	67	3
87	93	3
88	94	3
89	32	3
90	4	3
91	3	3
92	6	3
93	5	3
94	58	3
95	43	3
96	95	3
97	71	3
98	96	3
99	31	3
100	75	3
101	74	3
102	30	3
103	77	3
104	76	3
105	78	3
106	79	3
107	33	3
108	59	3
109	46	3
110	87	4
111	89	4
112	90	4
113	27	4
114	91	4
115	92	4
116	67	4
117	93	4
118	94	4
119	32	4
120	4	4
121	3	4
122	6	4
123	5	4
124	58	4
125	43	4
126	95	4
127	71	4
128	96	4
129	31	4
130	75	4
131	74	4
132	30	4
133	77	4
134	76	4
135	78	4
136	79	4
137	33	4
138	59	4
139	46	4
140	88	4
141	86	4
142	42	4
143	44	4
144	45	4
145	26	4
146	28	4
147	29	4
148	97	4
149	87	5
150	89	5
151	90	5
152	27	5
153	91	5
154	92	5
155	67	5
156	93	5
157	94	5
158	32	5
159	4	5
160	3	5
161	6	5
162	5	5
163	58	5
164	43	5
165	95	5
166	71	5
167	96	5
168	31	5
169	75	5
170	74	5
171	30	5
172	77	5
173	76	5
174	78	5
175	79	5
176	33	5
177	59	5
178	46	5
179	88	5
180	86	5
181	42	5
182	44	5
183	45	5
184	26	5
185	28	5
186	29	5
187	97	5
188	51	5
189	41	5
190	52	5
191	57	5
192	70	5
193	63	5
194	40	5
195	65	5
196	73	5
197	53	5
198	54	5
199	55	5
200	56	5
201	66	5
202	68	5
203	69	5
204	62	5
205	64	5
206	36	5
207	37	5
208	38	5
209	39	5
210	72	5
211	98	5
212	87	1
213	89	1
214	90	1
215	91	1
216	92	1
217	93	1
218	94	1
219	95	1
220	96	1
221	88	1
222	86	1
223	97	1
224	98	1
\.


--
-- Data for Name: ab_register_user; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.ab_register_user (id, first_name, last_name, username, password, email, registration_date, registration_hash) FROM stdin;
\.


--
-- Data for Name: ab_role; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.ab_role (id, name) FROM stdin;
1	Admin
2	Public
3	Viewer
4	User
5	Op
\.


--
-- Data for Name: ab_user; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.ab_user (id, first_name, last_name, username, password, active, email, last_login, login_count, fail_login_count, created_on, changed_on, created_by_fk, changed_by_fk) FROM stdin;
1	Admin	User	admin	pbkdf2:sha256:260000$YdGyvVnQCMUggDB6$28555d21019b9e173ce4c203d705dd5751c8c28f250a75d68ed3bf15a25aa188	t	admin@example.com	2025-07-21 12:37:23.548761	1	0	2025-07-21 12:36:16.39772	2025-07-21 12:36:16.397725	\N	\N
\.


--
-- Data for Name: ab_user_role; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.ab_user_role (id, user_id, role_id) FROM stdin;
1	1	1
\.


--
-- Data for Name: ab_view_menu; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.ab_view_menu (id, name) FROM stdin;
1	IndexView
2	UtilView
3	LocaleView
4	Passwords
5	My Password
6	My Profile
7	AuthDBView
8	Users
9	List Users
10	Security
11	Roles
12	List Roles
13	User Stats Chart
14	User's Statistics
15	Permissions
16	Actions
17	View Menus
18	Resources
19	Permission Views
20	Permission Pairs
21	AutocompleteView
22	Airflow
23	DAG Runs
24	Browse
25	Jobs
26	Audit Logs
27	Variables
28	Admin
29	Task Instances
30	Task Reschedules
31	Triggers
32	Configurations
33	Connections
34	SLA Misses
35	Plugins
36	Providers
37	Pools
38	XComs
39	DagDependenciesView
40	DAG Dependencies
41	RedocView
42	DevView
43	DocsView
44	DAGs
45	Cluster Activity
46	Datasets
47	Documentation
48	Docs
49	DAG:download_workflow
50	DAG:simple_test_workflow
51	DAG Code
52	ImportError
53	DAG Warnings
54	Task Logs
55	Website
56	DAG:veo_video_generation_workflow
57	DAG:image_generation_test_workflow
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.alembic_version (version_num) FROM stdin;
686269002441
\.


--
-- Data for Name: callback_request; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.callback_request (id, created_at, priority_weight, callback_data, callback_type, processor_subdir) FROM stdin;
\.


--
-- Data for Name: connection; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.connection (id, conn_id, conn_type, description, host, schema, login, password, port, is_encrypted, is_extra_encrypted, extra) FROM stdin;
1	airflow_db	mysql	\N	mysql	airflow	root	\N	\N	f	f	\N
2	athena_default	athena	\N	\N	\N	\N	\N	\N	f	f	\N
3	aws_default	aws	\N	\N	\N	\N	\N	\N	f	f	\N
4	azure_batch_default	azure_batch	\N	\N	\N	<ACCOUNT_NAME>	\N	\N	f	t	gAAAAABofjQ2BwW0ujcmJIwsCfnm-STLRNeY6icIBfCPAVH9BvlTNN980YEAyr-h5YGp_89RjvJpWu6atNc8wrrI04NIqjxMpv7v0H8BvNWEQ411OGsftLChH1nuoi5FfsRCmzG4jymh
5	azure_cosmos_default	azure_cosmos	\N	\N	\N	\N	\N	\N	f	t	gAAAAABofjQ2O0qGzT9aEyt9q-VV6Vk0PtCFf9MZ8HqAcy_LCCdLKWU8hO6UspQaCGr5wdfuXbR-I9Mur1oJGDQ7gV9uThQPE2g2s0nAQgF2ViBbxDvLT_N3eKePGHKUqB6o0vm1-vwvni8obopTtejHBQHtgDlk2NNeEQy_ZFDZp53sKIOC9iI=
6	azure_data_explorer_default	azure_data_explorer	\N	https://<CLUSTER>.kusto.windows.net	\N	\N	\N	\N	f	t	gAAAAABofjQ2lwvGX8-Hd5CtB04_NMVmUDrd9C1syPG2-nDvENi6CpzrK-wJBxwu7uaE15HRIMX1mvuW3lqk7ZdNs130eVp4TyQIQbPZ3I8hdRd5UzKVOfIm-VnMZfSd0vhTYfPuSWH2j7i4bpxprcSilXpJZkF0Ev0kBK3-Y2wHbOzoflK1ssfyORtrkRdxgQ1jgpySyTtttQuDBZGqs7dr5tAz5Kw7UA2TYuBJg9gsKIDVdwpa4uqJ4SEFobp9cqBraX5XmijaAVNvsYeVPdm9mMYZB-akHYOS2RN0azNlOmSG9L0ZMAUY9sBB2k1h9MCFC58KKL7ogkzhqKV4Erya8zRz-NMWSxCSScfjDWIRpwR1W-k3Y4E7hrWmze6CbYV3GP9Skptj
7	azure_data_lake_default	azure_data_lake	\N	\N	\N	\N	\N	\N	f	t	gAAAAABofjQ26nO47Fxq9_BsiMLwHxekI1uLAKsPpHHYY2lgpE_ge7C5QfTM9uEg8y_PiMlWdB9r3J9NVSFao_LkqJskyiKn08F2-8NyIdRsTUyn36dN-8NjdNUbTdA9EFUaxDvMC-E0VqH5TscwTkJfXsImhjJq7Q==
8	azure_default	azure	\N	\N	\N	\N	\N	\N	f	f	\N
9	cassandra_default	cassandra	\N	cassandra	\N	\N	\N	9042	f	f	\N
10	databricks_default	databricks	\N	localhost	\N	\N	\N	\N	f	f	\N
11	dingding_default	http	\N		\N	\N	\N	\N	f	f	\N
12	drill_default	drill	\N	localhost	\N	\N	\N	8047	f	t	gAAAAABofjQ28TCzJTDupasdQhpFefsR_XILYeDwFjNGVbNpkCIyZae49beJoktu5YX3IA2lUPGLl_5SgPtmDHd5Wag7FXPNBFy-F30OE_LS6MV8kbNGeyQUMXxpgI0bPaojJ0KGKN3SAnkcUKIclj0iBLybDX_zUg==
13	druid_broker_default	druid	\N	druid-broker	\N	\N	\N	8082	f	t	gAAAAABofjQ2m1eeNqWD-U18a8ShKvcWSvBbi_Cqmsargogoi8gfwdolIRbQ8HDy4oxeO5LIigfZ0oz5FL7bhLKMPfojBdLkt9uHqvaeQAkzJJISzJZvy4Q=
14	druid_ingest_default	druid	\N	druid-overlord	\N	\N	\N	8081	f	t	gAAAAABofjQ23_21IYFIWUvzDXfA_0V4fk_XlhYtLUaIkFgUJWRZ-n_8RIkCd8zd9_moNBPyLxRpZ0qre93ANbxF5fBvZ58r0mMh-V_He5YNR65wef12DL7z3-d6Q77RbzvNmEoRisvI
15	elasticsearch_default	elasticsearch	\N	localhost	http	\N	\N	9200	f	f	\N
16	emr_default	emr	\N	\N	\N	\N	\N	\N	f	t	gAAAAABofjQ2bFgRdB6W-Z3b6LHXcPtpnQEq5LHZWiUQO86ghQ63XK18E9Zcq_Q9rbasm2fXQPMHI5svOj8y6shmJYJBvFNorm5E_1feImYMs5zvacMOsLNaT2Re_FJ1IChc0oBaoDfCr-BUIrwkdZ9V14faBO60lK7RSOS5iFNs2SgoYs9WMn84S2IdY2UNnpIxQggwGOZy6gfdnCHvTiNQuliV8MTuPaGXnE3ykRLMKPNYIVYXNZaBrXRgOhrCY1iZejtY4KSDTAfrb2MQHSkwriQZuNiPzxO_eAHhApLtR2tObWtQfzrKlV-ewQnFa4__VP6VPrZ_pKFMyiN53tf5H1I5-xX4nvakLT0T8-ytIM7UKjzISmlgSBoM6U0lE0Ewfai0v4QB5aAXX8UhgId7_dIpnNiK5JaAkBNdCheRloOemhhgsWteg_ok_nMIHVP0MWA9cXBJ_ts9PGYs9AvUVVdZcpo62ECkP6PftOkIcT3D-X4NeTZUjF3vp_8hTcJGeZNgqTShzupOhzUt0iWviClJQf6jkn_EowPpixO9l-41_U1UG9_2Kv5Cd3BxWnc_UMGoqc2SviXqmoSgY1cEeTc2ze-l-rG1y8dPuukY3-xvz4Tpv1GJsxRtTtLIHuvq2D6Nyv8vc9Ri-nA8u6h9k_4bBtUGGPcss-ClzxR628j2JNzm_I3pUdusdRHw3_jhm8DCT_b_OYOtNY2gg4jkYoheN3XG4e970xebaB37IDGatgGFBfFlGn16uEacKMQZbzmNhT7YLi3p0WdkesLaRtQbRSP1LDtr206pA9dFT80DyGbi3VaijKxrXRQIxGsdna0xbuVoFhlmZXgZlUdZy8zT1epTVEaMKs9sgDm1rdtgLztvR9JeBp9ESBte2fE4Q8c7x6a56FbhdAZUYMXuzqAZg7j4uoLrTRaUCUuLzTYsfROcO_KF7aDzZacHCcPEsY8KZurtUL6qcec0bC3Ns1ZaLPZeqkRfjICar1VfvLcBoKnXhWEcMdX7RdGuTQ5W_OHHXUDpIjl8DHv50_HbHbwUSkUFbdxfa4zIlBGUDG5ErzUd-dlXKUEbBKnkrIL0l4Cn3n8icMsMXV1-lHU9I73GzL7fATw4RBxQgtIOUgYvCvHFJn1hXbf18C6xkIlKqfdv9hBDTa57dLoCEidwjYHMWzCsXSiKaN-mScoD2UJSqQILssBOj2ODu40hNOstTtDh1lmqVMQ7vZEU4sep9nGhpvKLEz2QnNdknFbu8w8psbKj1JddTJ0H-DjRz4rEHZ-hJ7ZGWAiROPOTx_nKmqqtlsU7yRH3KBtdGc29R9BRcmmyo2Ga6Wvf2z-m4M_TLJI318i7FTvktnJcf0u9YnwsdhYDPM__8TrCQDIIxSxcfcjvneThGm5_sM8D84VD9LrR3cnxT7BGbq4OgVs23bBpyzK6nt6X3t_SKst1kUwM1EspO1dWHXCtY7XkUVushE5JXypQ3TJm_Xd3NV5P97bhCTaIETbO4uEiMi2utXjAmghvOP0AEjsWfYxQcq058XmHcJFxfTQIv_G119salpOv2D6KtrbtXlkrWRpEq3gPpclitJ2DDxRpK7yrO2Zl5spHUtrRxeAf2g8sgYIllPiylPEy2Rg7oMe7NlSX2fuQerbs5KoliCOdo-yt_dMABcodk6jvfp6C8f6Rbu8dFwuTRg6Zyuv7Kks3dg7THtvEgf4GWGKIdTe2MazytW3lxjiXyGO0Qcqbw0fcR0VidHcuZ0b6NU83zS3D7ADjvZD-GKbkiNQr2QcXPtiZJc82-LG_f-XPlFxIqFupUeItQie1fKu8LuNBkimyCJYEjDBOIJmW7kJBJ_WWWNSgwUzwAgkg1r8-eXAcaWb81a5VZ265O4qEJBclvGOKYQm6gHbTM49BlIwC1xf0uqFcJO3kQroCFz1-6miN3mV6wNziEMLYvQ4VIFLMUrmtZGPabk8LUQRulk_s2NL-RngsdN7GYxsqDMgKB01Fe1Q5dYSxwU-oZkOvqrUo4N0omH4SPwDDoCuIkm6TkdXHtmcHFx97mptPHv3DD-qS2gVpAAJ93uI-lE5ZpnmGRNs9sV-9J6ffUsYJZQlBIuD3BMjlDK_soKleNgGmtLZBo1Sr1tc3hdTJJgqAeShbwSYw94aCByd-Vo705oeahPpbCzoX16lR3BSTveTx79r45Fw-Bcw-MM6uOfvOOs_k7E09sTL2zL93dBHCLiEBj2-XFbktb4zqE95DrcZE3hs4SCq4iDekzfxZnFSjc9AT7-HEMLluFMEnGfgRQpzOPiWP-uanqdLkSKKVsyPSAMcPhkHyOJg4udHFAXIRDqAS2L2YkB2U9HQH7M6C0TR0aR7QmH0bHVCxPiRWNKN0xPE3m8bFQmZsLQW7EGXD752T9ov0VSDiI2EvpAzh9mZuDJhF0etYVz3PD9wf2_Y2coMwaFjnMtMyv-85MwTryUXy8ouYWt7fcynta_UC5XZzq6dk6pTrsU1l71G0nSilOFcqwcR23IdHz1Nd60Xz15Ik8398BsHh4W6j70_byNY=
17	facebook_default	facebook_social	\N	\N	\N	\N	\N	\N	f	t	gAAAAABofjQ2ewvQvu7VsQ0mzXRU6mr8G1mJ24puS9X_bzyShdwl-PCbzz9J9kpIwlXKpgtszHGKbKKDYtrq-Tbc7qTg7cWzn6CJ1u25PWg4EG77rVIZfEc5MmUS9babU13yJUHdSz0jJ9dvYL33rfnOYanstEqf8Ge08LOPgWBpaz8YbHUNMugdRQLlzBOzLvpTgiH-qj1tPYXC_ZXrpq8611AnZEyF2wMSMHGV-O-35PmcLY_9LAEjvwzmLC4hqOtRzUQryY7gNGtGSZEHttcu0TLmteauWTAwLWpQgQcvX0p_CN5uV2Ozt4GsnxMGsB_5x-x7PHgWV5W88mO9dlg4LCUSWH1GHo6n0mik8Y9phVTXACP37ErA9JTjTjbvJ-cFZ6cmXAusqv-Ao3WYC_GTpqwKzroFTLX0WFMCRx2IixbRnPfBt7c=
18	fs_default	fs	\N	\N	\N	\N	\N	\N	f	t	gAAAAABofjQ2FMZMYd1GbJn85mKQsCy_bD_JKsJv6kzkxTukDVlfSROFgTpj91u-CkODyL1Oj_7Phlcd6-oodOcicXjruc7sRQ==
19	ftp_default	ftp	\N	localhost	\N	airflow	gAAAAABofjQ2V9LoSk38429zO60Xii4xqwpWcGMdlB2Ojt9V1-44v9b2RwgIGM0TPnvrMH-7J9Mn0lkf-MK0ja7RjJTavDmAUA==	21	t	t	gAAAAABofjQ20PfpgvPdOQnxu7UTffhzZai6CyID7F69J7rmO7SKOqLpInLIsQ95jWZh09Stec3CmMbHAWpq8d-07BOF2KhhagYHOkjPBIoN84FO8UnA4fGWdNOdPAGHfbOypF_gL74DIHNx-uaDLdyEbEHVw7pBDA==
20	google_cloud_default	google_cloud_platform	\N	\N	default	\N	\N	\N	f	f	\N
21	hive_cli_default	hive_cli	\N	localhost	default	\N	\N	10000	f	t	gAAAAABofjQ2Itx8e7ld9UbO81JZkOsk6u7yiroa03SYadlucnFHK5wnajIPMAT1DrxJWGLHQuvDeAitgkH0ESCp8SROiAOYuFal1okOWRu8KaJKBItvDuYPEfOx3hC2J65Z8KRF7RUb
22	hiveserver2_default	hiveserver2	\N	localhost	default	\N	\N	10000	f	f	\N
23	http_default	http	\N	https://www.httpbin.org/	\N	\N	\N	\N	f	f	\N
24	impala_default	impala	\N	localhost	\N	\N	\N	21050	f	f	\N
25	kafka_default	kafka	\N	\N	\N	\N	\N	\N	f	t	gAAAAABofjQ2PuX0Ng3eMUF2cvfRLp5-8OvZpfkD3PT4QmVIZKbQOalc_Sa4bEw8fjwrIPHLpQ3xbDgCzHv3qay3Ia5rxFxGCebzeGFcDvU3XPPSeOgrOpVPicpaslTUX5o-c4rVRTrd
26	kubernetes_default	kubernetes	\N	\N	\N	\N	\N	\N	f	f	\N
27	kylin_default	kylin	\N	localhost	\N	ADMIN	gAAAAABofjQ2ThM9yabfQWi6hn7LDWuDVZQStZDKTsagb6WbjIauTaziiY6uNawB_xhJgpvQzgabItpDFbQ_zZgwv_QlE35B6A==	7070	t	f	\N
28	leveldb_default	leveldb	\N	localhost	\N	\N	\N	\N	f	f	\N
29	livy_default	livy	\N	livy	\N	\N	\N	8998	f	f	\N
30	local_mysql	mysql	\N	localhost	airflow	airflow	gAAAAABofjQ2AnBOULShM-ypEjX1FF4DBtIBknHsYfZQS_KciXJceMn4jBtsViLFUL3hyfWURZqcHe4MZALTLXeLIF3H1zcxyA==	\N	t	f	\N
31	metastore_default	hive_metastore	\N	localhost	\N	\N	\N	9083	f	t	gAAAAABofjQ2a5ukUSBLX-syH3r2NQMQffO9rKDOwzgg-2Xx3zWdpL4QGs0ark-BNiUvh3eHsDf9J9UFYzoixMMfkTAAYCnoaTNWwig52508lTSYGwf44lw=
32	mongo_default	mongo	\N	mongo	\N	\N	\N	27017	f	f	\N
33	mssql_default	mssql	\N	localhost	\N	\N	\N	1433	f	f	\N
34	mysql_default	mysql	\N	mysql	airflow	root	\N	\N	f	f	\N
35	opsgenie_default	http	\N		\N	\N	\N	\N	f	f	\N
36	oracle_default	oracle	\N	localhost	schema	root	gAAAAABofjQ20mgTut_xaugDgUhDDgUDZ5UOCxM7bssGAWs0aykpjO2kIONhTFbUPvxCH0V73K1DKraPU93rb07-8Dwe38jhGw==	1521	t	f	\N
37	oss_default	oss	\N	\N	\N	\N	\N	\N	f	t	gAAAAABofjQ25uT_QULUOL5DX7bTnxa-QvlW-PIJv3ENzqSuVOACgOkoCGym_UssT0DeVl0KZRZx1-NaZhxOYRgR7BCJcQlmJDV540b1vJ-xx9v62ttK7QjKaPUq8JNlBsb1pArOfmvBoQr6Q3vk2U3JxQhA4i4UTdErZtCSSLTav_q3Pj8ZqnTLxSg8FuXqN3taaf5d_9gr49NNVd5UFBskyn1rkf2b7-oQe0gJ9c6Q627NIRutROpdsZMcBeVFomQwg5_TG0qnoudn-ae0xi5_3pR7JeK12n_POX3lTlC9r64lBq3L3A4gwob4eFSIFRxDMEhL6PAoUiMTw75sdpOEbrcBjCNQnY5qFLcN8iIP9jQfyDgf3CM=
38	pig_cli_default	pig_cli	\N	\N	default	\N	\N	\N	f	f	\N
39	pinot_admin_default	pinot	\N	localhost	\N	\N	\N	9000	f	f	\N
40	pinot_broker_default	pinot	\N	localhost	\N	\N	\N	9000	f	t	gAAAAABofjQ2GxwA3fusgeBF3smOQpJNM4V-lrLNHmyZGzUX2C2xoPhUsyizeA12jTzl7Jp9VXTCNNYwy_AkGQGOZVbhnHKJsuPLH7r07Oj52QHanEumsqk3Z3IGSvNKzYumT0s9TNV9
41	postgres_default	postgres	\N	postgres	airflow	postgres	gAAAAABofjQ2u_ABchasUh5s670VeT9wrksE4itRrr4GYfQD37g7ysRCa2-OB4sApqvatpspc-2EpZPXsz6HF5EyfgRIR4jm9g==	\N	t	f	\N
42	presto_default	presto	\N	localhost	hive	\N	\N	3400	f	f	\N
43	qdrant_default	qdrant	\N	qdrant	\N	\N	\N	6333	f	f	\N
44	redis_default	redis	\N	redis	\N	\N	\N	6379	f	t	gAAAAABofjQ2qc52fyifdnWLuhscTA-A2Pj3iVb8Vt9j90pb07PNYvvGHxJnsS2k1exKq07w4RVhrwIV4MxQ4w0wxX4gysCeZA==
45	redshift_default	redshift	\N	\N	\N	\N	\N	\N	f	t	gAAAAABofjQ22Nj13Gf5uX7wQHoPT0Qaj8-CUvSxU57QYW6uoCpyZOXLeNFNmNEWNNOc2ouBYLC8utNapxwKkkuvbjraGD6EGAUfu6IolGaEPoFsAspUQU-jwkafaIvDV0So-0YtCKZQ-rCrFs4R6CqhNtuA9_yRrTqsn3y0flWK43X1vacW9TWNs6slE8sWgjEYzqlJx_sf2ek1Mun73hGKNK6cziH8WBY_waEp-HR3qrckPWVSMiceJBr1Tppz0Tl0xspsyRKVic64S78mSMpQ6yEMHWyUpgfYy8nVb_wZ816t5L8LPlOqeNtdAQV8k7AVI8gyQ4vT
46	salesforce_default	salesforce	\N	\N	\N	username	gAAAAABofjQ2_-la9wshScEYyBoMhhFPwvSJqVDkgxFPQnNEUiRZtJvon69c9VpivslJ-9O_dLMXcQANPtCXy8oKqPWHr7zXaA==	\N	t	t	gAAAAABofjQ2Jcj6eegpIFIDnSK7qfDpQO-XTQoyXm423S9yk3FTNoGQsMp8wFiRPQnFfvsJjX0yTjaBVqJyEkVg-_YpPzlkjVBawFkkyEDnMlYypD2zpL1PdyL_2UhVnWpFwiWeE92Q
47	segment_default	segment	\N	\N	\N	\N	\N	\N	f	t	gAAAAABofjQ2_ovH1IEFu9J8d5zbluOYWKbsBGEcja7FiU_YDvt72Rt0PUih0uiZLb5ENTos8S0VQQVtUljutYIOF9-WaA1OH9CEfRvRKo0QaAv441T7SV4FycSf1SN1SyIjU9qa6PMp
50	sqlite_default	sqlite	\N	/tmp/sqlite_default.db	\N	\N	\N	\N	f	f	\N
53	tabular_default	tabular	\N	https://api.tabulardata.io/ws/v1	\N	\N	\N	\N	f	f	\N
56	vertica_default	vertica	\N	localhost	\N	\N	\N	5433	f	f	\N
59	yandexcloud_default	yandexcloud	\N	\N	default	\N	\N	\N	f	f	\N
48	sftp_default	sftp	\N	localhost	\N	airflow	\N	22	f	t	gAAAAABofjQ2txDGpuJw7_iIKAxL6tKmaEjcGiwJ3eUy48CVzALRJ5v-GhAEM0jSrqHljKukRCkBBBt2wNz_-OCxwclTVCC3aAztKT2QtQ2L_DJ8kd84jfDpMKj2KvzJlRa2ygiLzz7xFJ_KBe_23oZTsD-7UGoyrg==
51	ssh_default	ssh	\N	localhost	\N	\N	\N	\N	f	f	\N
54	teradata_default	teradata	\N	localhost	schema	user	gAAAAABofjQ2MsaKBtu9qUPEeuD3OO-IRC-HZEqQyq6PNqyIJbWr6ybgtw8VByfytLJ4QUrRS695OdDH8jETB4SutB0UO1ekxQ==	\N	t	f	\N
57	wasb_default	wasb	\N	\N	\N	\N	\N	\N	f	t	gAAAAABofjQ2QNgw-55xDicunxPbS3c6P1eqf35bnyRRM4Dr8K2ZiWhUXC_T6wQ1CkTCq7MgQhEBenEpIUk6Was9ICgVy5J3GjdZbYYAzCS2EI3XMtX75i4=
49	spark_default	spark	\N	yarn	\N	\N	\N	\N	f	t	gAAAAABofjQ2wKFg5HmfGoTMf4IQA2vX74YhHt9yVy-Sbt2RcN7bC8bKVPmRw9hnQU-EPb_PCU7g3kuALq6kjiP1XbRPcf2ayzGOrPdXXlwct2Uu33Bh1iw=
52	tableau_default	tableau	\N	https://tableau.server.url	\N	user	gAAAAABofjQ2hjwxgs8g38sRiWkzs6BVkg_HWenFK0QodjD4_O1bgZXjNpyWQVJ4ZfngG1h1grAV2TiKUhaGxG3a95mKOgv5QA==	\N	t	t	gAAAAABofjQ2ci-gc6oXLs6pMbx1XRDKgIdpSK8K6g7tuw8QUfUomrn8PbvkjR9QdKI-d0bmA62jTuIlKfKvK87dLJ-S2ieUOB6bmnfVVNgz-ltWzoIhKkQ=
55	trino_default	trino	\N	localhost	hive	\N	\N	3400	f	f	\N
58	webhdfs_default	hdfs	\N	localhost	\N	\N	\N	50070	f	f	\N
\.


--
-- Data for Name: dag; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dag (dag_id, root_dag_id, is_paused, is_subdag, is_active, last_parsed_time, last_pickled, last_expired, scheduler_lock, pickle_id, fileloc, processor_subdir, owners, dag_display_name, description, default_view, schedule_interval, timetable_description, dataset_expression, max_active_tasks, max_active_runs, max_consecutive_failed_dag_runs, has_task_concurrency_limits, has_import_errors, next_dagrun, next_dagrun_data_interval_start, next_dagrun_data_interval_end, next_dagrun_create_after) FROM stdin;
simple_test_workflow	\N	t	f	t	2025-07-21 12:51:40.081427+00	\N	\N	\N	\N	/opt/airflow/dags/simple_test_dag.py	/opt/airflow/dags	ai-team	\N	简化的测试工作流	grid	null	Never, external triggers only	null	16	16	0	f	f	\N	\N	\N	\N
download_workflow	\N	t	f	t	2025-07-21 12:51:40.096924+00	\N	\N	\N	\N	/opt/airflow/dags/download_workflow_dag.py	/opt/airflow/dags	ai-team	\N	异步下载生成的文件	grid	{"type": "timedelta", "attrs": {"days": 0, "seconds": 300, "microseconds": 0}}		null	16	1	0	f	f	2025-07-21 12:45:00+00	2025-07-21 12:45:00+00	2025-07-21 12:50:00+00	2025-07-21 12:50:00+00
image_generation_test_workflow	\N	t	f	t	2025-07-21 12:51:48.0379+00	\N	\N	\N	\N	/opt/airflow/dags/test_image_generation_dag.py	/opt/airflow/dags	ai-team	\N	测试图像生成工作流 - 仅用于测试目的	grid	null	Never, external triggers only	null	1	1	0	f	f	\N	\N	\N	\N
veo_video_generation_workflow	\N	t	f	t	2025-07-21 12:51:54.798636+00	\N	\N	\N	\N	/opt/airflow/dags/veo_video_generation_dag.py	/opt/airflow/dags	ai-team	\N	企业级Veo视频生成工作流	grid	null	Never, external triggers only	null	16	16	0	f	f	\N	\N	\N	\N
\.


--
-- Data for Name: dag_code; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dag_code (fileloc_hash, fileloc, last_updated, source_code) FROM stdin;
52857970949920226	/opt/airflow/dags/download_workflow_dag.py	2025-07-21 12:36:26.561072+00	#!/usr/bin/env python3\n"""\n下载工作流DAG - 异步下载生成的文件\n"""\n\nfrom datetime import datetime, timedelta\nfrom airflow import DAG\nfrom airflow.decorators import task\nfrom airflow.operators.python import PythonOperator\nfrom airflow.operators.bash import BashOperator\nimport os\nimport sys\nimport asyncio\nimport logging\n\n# 添加src目录到Python路径\nsys.path.insert(0, '/opt/airflow/src')\n\nfrom src.downloader import file_downloader\nfrom src.job_manager import JobManager\n\n# 设置日志\nlogging.basicConfig(level=logging.INFO)\nlogger = logging.getLogger(__name__)\n\n# DAG默认参数\ndefault_args = {\n    'owner': 'ai-team',\n    'depends_on_past': False,\n    'start_date': datetime(2025, 1, 1),\n    'email_on_failure': False,\n    'email_on_retry': False,\n    'retries': 2,\n    'retry_delay': timedelta(minutes=5),\n}\n\n# 创建DAG\ndag = DAG(\n    'download_workflow',\n    default_args=default_args,\n    description='异步下载生成的文件',\n    schedule_interval=timedelta(minutes=5),  # 每5分钟检查一次\n    catchup=False,\n    max_active_runs=1,\n    params={\n        "file_type": "all",  # 文件类型过滤: image/video/all\n        "max_downloads": 10,  # 每次最大下载数量\n        "priority_threshold": 0,  # 优先级阈值\n        "force_redownload": False,  # 强制重新下载\n    }\n)\n\n@task(task_id="scan_download_queue")\ndef scan_download_queue(**context) -> dict:\n    """扫描下载队列，获取待下载任务"""\n    \n    # 获取DAG参数\n    params = context.get('params', {})\n    file_type = params.get('file_type', 'all')\n    max_downloads = params.get('max_downloads', 10)\n    priority_threshold = params.get('priority_threshold', 0)\n    \n    logger.info(f"扫描下载队列，文件类型: {file_type}, 最大数量: {max_downloads}")\n    \n    job_manager = JobManager()\n    \n    # 获取待下载任务\n    filter_type = None if file_type == 'all' else file_type\n    pending_downloads = job_manager.get_pending_downloads(\n        limit=max_downloads, \n        file_type=filter_type\n    )\n    \n    # 过滤优先级\n    filtered_downloads = [\n        task for task in pending_downloads \n        if task['priority'] >= priority_threshold\n    ]\n    \n    logger.info(f"找到 {len(filtered_downloads)} 个待下载任务")\n    \n    return {\n        'download_tasks': filtered_downloads,\n        'total_count': len(filtered_downloads),\n        'file_type_filter': file_type\n    }\n\n@task(task_id="prepare_download_batch")\ndef prepare_download_batch(scan_result: dict, **context) -> dict:\n    """准备下载批次"""\n    \n    download_tasks = scan_result['download_tasks']\n    \n    if not download_tasks:\n        logger.info("没有待下载的任务")\n        return {\n            'has_downloads': False,\n            'batch_info': {}\n        }\n    \n    # 按优先级和文件类型分组\n    image_tasks = []\n    video_tasks = []\n    \n    for task in download_tasks:\n        if task['file_type'] == 'image':\n            image_tasks.append(task)\n        elif task['file_type'] == 'video':\n            video_tasks.append(task)\n    \n    # 构建下载批次\n    batch_info = {\n        'image_tasks': image_tasks,\n        'video_tasks': video_tasks,\n        'total_images': len(image_tasks),\n        'total_videos': len(video_tasks),\n        'estimated_duration': estimate_download_time(download_tasks)\n    }\n    \n    logger.info(f"准备下载批次 - 图像: {len(image_tasks)}, 视频: {len(video_tasks)}")\n    \n    return {\n        'has_downloads': True,\n        'batch_info': batch_info\n    }\n\ndef estimate_download_time(tasks: list) -> int:\n    """估算下载时间（秒）"""\n    # 简单估算：图像5秒，视频30秒\n    total_seconds = 0\n    for task in tasks:\n        if task['file_type'] == 'image':\n            total_seconds += 5\n        elif task['file_type'] == 'video':\n            total_seconds += 30\n    return total_seconds\n\n@task(task_id="download_images")\ndef download_images(batch_info: dict, **context) -> dict:\n    """下载图像文件"""\n    \n    logger.info(f"接收到的batch_info: {batch_info}")\n    \n    # 检查参数有效性\n    if not batch_info:\n        logger.warning("batch_info为None，尝试从数据库重新获取任务")\n        job_manager = JobManager()\n        pending_downloads = job_manager.get_pending_downloads(limit=10, file_type='image')\n        if pending_downloads:\n            image_tasks = pending_downloads\n            logger.info(f"从数据库获取到 {len(image_tasks)} 个图像下载任务")\n        else:\n            logger.info("跳过图像下载，没有任务")\n            return {'downloaded': 0, 'failed': 0}\n    elif not batch_info.get('has_downloads', False):\n        logger.info("跳过图像下载，没有任务")\n        return {'downloaded': 0, 'failed': 0}\n    else:\n        image_tasks = batch_info['batch_info']['image_tasks']\n    \n    if not image_tasks:\n        logger.info("没有图像下载任务")\n        return {'downloaded': 0, 'failed': 0}\n    \n    logger.info(f"开始下载 {len(image_tasks)} 个图像文件")\n    \n    job_manager = JobManager()\n    downloaded = 0\n    failed = 0\n    \n    for task in image_tasks:\n        try:\n            # 更新状态为下载中\n            job_manager.update_download_status(task['id'], 'downloading')\n            \n            # 执行下载\n            result = file_downloader.download_file_sync(\n                task['remote_url'], \n                task['local_path'],\n                resume=True\n            )\n            \n            if result['success']:\n                # 更新为完成状态\n                job_manager.update_download_status(\n                    task['id'], \n                    'completed',\n                    file_size=result['file_size']\n                )\n                downloaded += 1\n                logger.info(f"图像下载成功: {task['local_path']}")\n            else:\n                # 更新为失败状态\n                job_manager.update_download_status(\n                    task['id'], \n                    'failed',\n                    error_message=result['error']\n                )\n                failed += 1\n                logger.error(f"图像下载失败: {result['error']}")\n        \n        except Exception as e:\n            job_manager.update_download_status(\n                task['id'], \n                'failed',\n                error_message=str(e)\n            )\n            failed += 1\n            logger.error(f"图像下载异常: {e}")\n    \n    logger.info(f"图像下载完成 - 成功: {downloaded}, 失败: {failed}")\n    \n    return {\n        'downloaded': downloaded,\n        'failed': failed,\n        'type': 'image'\n    }\n\n@task(task_id="download_videos")\ndef download_videos(batch_info: dict, **context) -> dict:\n    """下载视频文件"""\n    \n    logger.info(f"接收到的batch_info: {batch_info}")\n    \n    # 检查参数有效性\n    if not batch_info:\n        logger.warning("batch_info为None，尝试从数据库重新获取任务")\n        job_manager = JobManager()\n        pending_downloads = job_manager.get_pending_downloads(limit=10, file_type='video')\n        if pending_downloads:\n            video_tasks = pending_downloads\n            logger.info(f"从数据库获取到 {len(video_tasks)} 个视频下载任务")\n        else:\n            logger.info("跳过视频下载，没有任务")\n            return {'downloaded': 0, 'failed': 0}\n    elif not batch_info.get('has_downloads', False):\n        logger.info("跳过视频下载，没有任务")\n        return {'downloaded': 0, 'failed': 0}\n    else:\n        video_tasks = batch_info['batch_info']['video_tasks']\n    \n    if not video_tasks:\n        logger.info("没有视频下载任务")\n        return {'downloaded': 0, 'failed': 0}\n    \n    logger.info(f"开始下载 {len(video_tasks)} 个视频文件")\n    \n    job_manager = JobManager()\n    downloaded = 0\n    failed = 0\n    \n    for task in video_tasks:\n        try:\n            # 更新状态为下载中\n            job_manager.update_download_status(task['id'], 'downloading')\n            \n            # 执行下载（视频文件通常较大，使用更长超时）\n            result = file_downloader.download_file_sync(\n                task['remote_url'], \n                task['local_path'],\n                resume=True\n            )\n            \n            if result['success']:\n                # 更新为完成状态\n                job_manager.update_download_status(\n                    task['id'], \n                    'completed',\n                    file_size=result['file_size']\n                )\n                downloaded += 1\n                logger.info(f"视频下载成功: {task['local_path']}")\n            else:\n                # 更新为失败状态\n                job_manager.update_download_status(\n                    task['id'], \n                    'failed',\n                    error_message=result['error']\n                )\n                failed += 1\n                logger.error(f"视频下载失败: {result['error']}")\n        \n        except Exception as e:\n            job_manager.update_download_status(\n                task['id'], \n                'failed',\n                error_message=str(e)\n            )\n            failed += 1\n            logger.error(f"视频下载异常: {e}")\n    \n    logger.info(f"视频下载完成 - 成功: {downloaded}, 失败: {failed}")\n    \n    return {\n        'downloaded': downloaded,\n        'failed': failed,\n        'type': 'video'\n    }\n\n@task(task_id="update_download_stats")\ndef update_download_stats(image_result: dict, video_result: dict, **context) -> dict:\n    """更新下载统计信息"""\n    \n    total_downloaded = image_result['downloaded'] + video_result['downloaded']\n    total_failed = image_result['failed'] + video_result['failed']\n    \n    logger.info(f"本次下载统计 - 总成功: {total_downloaded}, 总失败: {total_failed}")\n    \n    # 获取整体统计\n    job_manager = JobManager()\n    stats = job_manager.get_download_stats()\n    \n    logger.info(f"整体下载统计: {stats}")\n    \n    return {\n        'current_batch': {\n            'images_downloaded': image_result['downloaded'],\n            'images_failed': image_result['failed'],\n            'videos_downloaded': video_result['downloaded'],\n            'videos_failed': video_result['failed'],\n            'total_downloaded': total_downloaded,\n            'total_failed': total_failed\n        },\n        'overall_stats': stats\n    }\n\n@task(task_id="cleanup_old_records")\ndef cleanup_old_records(**context) -> dict:\n    """清理旧的下载记录"""\n    \n    job_manager = JobManager()\n    \n    # 清理7天前的已完成下载记录\n    cleaned_count = job_manager.cleanup_old_downloads(days=7)\n    \n    logger.info(f"清理了 {cleaned_count} 条旧下载记录")\n    \n    return {'cleaned_records': cleaned_count}\n\n# 定义任务依赖关系\nwith dag:\n    scan_result = scan_download_queue()\n    batch_info = prepare_download_batch(scan_result)\n\n    # 并行下载图像和视频\n    image_result = download_images(batch_info)\n    video_result = download_videos(batch_info)\n\n    # 更新统计和清理\n    stats_result = update_download_stats(image_result, video_result)\n    cleanup_result = cleanup_old_records()\n\n    # 设置依赖关系\n    scan_result >> batch_info >> [image_result, video_result] >> stats_result >> cleanup_result 
51986830495754876	/opt/airflow/dags/simple_test_dag.py	2025-07-21 12:36:26.661206+00	"""\n简化的测试DAG，用于验证模块导入\n"""\n\nimport sys\nimport os\nfrom datetime import datetime, timedelta\nfrom airflow import DAG\nfrom airflow.decorators import dag, task\nimport logging\n\n# 添加src目录到Python路径\nsys.path.append('/opt/airflow/src')\n\nlogger = logging.getLogger(__name__)\n\n# DAG配置\ndefault_args = {\n    'owner': 'ai-team',\n    'depends_on_past': False,\n    'start_date': datetime(2024, 1, 1),\n    'email_on_failure': False,\n    'email_on_retry': False,\n    'retries': 1,\n    'retry_delay': timedelta(minutes=5),\n}\n\n@dag(\n    dag_id='simple_test_workflow',\n    default_args=default_args,\n    description='简化的测试工作流',\n    schedule=None,\n    catchup=False,\n    tags=['test', 'simple']\n)\ndef simple_test_dag():\n    """\n    简化的测试DAG\n    """\n    \n    @task(task_id='test_import')\n    def test_import():\n        """测试模块导入"""\n        try:\n            # 测试导入\n            from src.core_workflow import get_and_lock_job\n            logger.info("✅ 成功导入 core_workflow 模块")\n            \n            from src.database import db_manager\n            logger.info("✅ 成功导入 database 模块")\n            \n            from src.image_generator import ImageGenerator\n            logger.info("✅ 成功导入 image_generator 模块")\n            \n            return "所有模块导入成功"\n            \n        except ImportError as e:\n            logger.error(f"❌ 模块导入失败: {e}")\n            raise\n        except Exception as e:\n            logger.error(f"❌ 其他错误: {e}")\n            raise\n    \n    @task(task_id='test_database')\n    def test_database():\n        """测试数据库连接"""\n        try:\n            from src.database import db_manager\n            \n            # 测试数据库连接\n            with db_manager.get_connection() as conn:\n                with conn.cursor() as cursor:\n                    cursor.execute("SELECT 1")\n                    result = cursor.fetchone()\n                    if result and result[0] == 1:\n                        logger.info("✅ 数据库连接测试成功")\n                        return "数据库连接正常"\n                    else:\n                        raise Exception("数据库连接测试失败")\n                        \n        except Exception as e:\n            logger.error(f"❌ 数据库测试失败: {e}")\n            raise\n    \n    # 定义任务流程\n    import_test = test_import()\n    db_test = test_database()\n    \n    # 设置任务依赖\n    import_test >> db_test\n\n# 创建DAG实例\nsimple_dag = simple_test_dag() 
57622103943375835	/opt/airflow/dags/test_image_generation_dag.py	2025-07-21 12:47:35.985904+00	"""\n⚠️ 测试图像生成DAG ⚠️\n\n此DAG仅用于测试目的，使用低成本的文本到图像模型。\n生成的数据标记为"测试数据"，便于清理。\n\n重要警告：\n- 此DAG仅用于开发和测试环境\n- 使用低成本模型，生成质量可能较低\n- 生成的文件会自动标记为测试数据\n- 请勿在生产环境中使用此DAG\n"""\n\nimport sys\nimport os\nfrom datetime import datetime, timedelta\nfrom airflow import DAG\nfrom airflow.decorators import dag, task\nimport logging\n\n# 添加src目录到Python路径\nsys.path.append('/opt/airflow/src')\n\nlogger = logging.getLogger(__name__)\n\n\n\n# DAG配置\ndefault_args = {\n    'owner': 'ai-team',\n    'depends_on_past': False,\n    'start_date': datetime(2024, 1, 1),\n    'email_on_failure': False,\n    'email_on_retry': False,\n    'retries': 1,\n    'retry_delay': timedelta(minutes=5),\n}\n\n# DAG文档\ndag_doc = """\n# 测试图像生成工作流\n\n## ⚠️ 重要警告 ⚠️\n\n**此DAG仅用于测试目的！**\n\n### 使用说明：\n- 此DAG使用低成本的文本到图像模型\n- 生成的文件会自动标记为测试数据（文件名包含`_image_test`）\n- 生成的数据质量可能较低，仅用于验证工作流程\n- 请勿在生产环境中使用此DAG\n\n### Dry Run模式（默认）：\n- **默认启用**：Dry Run模式默认开启，确保零API成本\n- **占位符文件**：创建`.txt`占位符文件而不是真实图像\n- **完整测试**：验证所有数据库操作、任务依赖和文件I/O\n- **安全第一**：防止意外API调用和成本产生\n\n### 真实模式：\n- 手动关闭Dry Run开关以启用真实API调用\n- 生成真实的`.png`图像文件\n- 会产生Google Vertex AI API成本\n- 仅用于最终测试和验证\n\n### 工作流程：\n1. 从数据库获取待处理的IMAGE_TEST类型作业\n2. 根据Dry Run设置决定是否调用API\n3. 保存图像或占位符文件到本地outputs目录\n4. 更新作业状态为完成\n\n### 清理：\n- 测试文件会在24小时后自动清理\n- 可以通过手动触发清理任务来立即清理旧文件\n\n### 注意事项：\n- 确保Google Cloud凭据已正确配置\n- 确保数据库连接正常\n- 监控生成的文件大小和存储空间\n- **重要**：Dry Run模式默认开启，确保测试安全\n"""\n\n@dag(\n    dag_id='image_generation_test_workflow',\n    default_args=default_args,\n    description='测试图像生成工作流 - 仅用于测试目的',\n    schedule=None,  # 手动触发\n    catchup=False,\n    tags=['test', 'image-generation', 'development'],\n    doc_md=dag_doc,\n    max_active_runs=1,  # 限制并发运行\n    concurrency=1,\n    params={\n        "dry_run": {\n            "type": "boolean",\n            "default": False,\n            "title": "Dry Run Mode",\n            "description": "If True, skips the actual API call and creates a placeholder file. Set to False for real API calls."\n        }\n    }\n)\ndef test_image_generation_dag():\n    """\n    测试图像生成DAG\n    \n    此DAG仅用于测试目的，使用低成本的文本到图像模型。\n    生成的数据标记为"测试数据"，便于清理。\n    """\n    \n    # 在DAG函数内部导入模块\n    try:\n        from src.core_workflow import get_and_lock_job, mark_job_as_completed, mark_job_as_failed\n        from src.image_generator import ImageGenerator\n        from src.database import db_manager\n    except ImportError as e:\n        logger.error(f"导入模块失败: {e}")\n        raise\n    \n    @task(task_id='initialize_database')\n    def initialize_database():\n        """初始化数据库连接"""\n        try:\n            # 只在表不存在时初始化\n            if not db_manager.check_table_exists('jobs'):\n                db_manager.init_database()\n                logger.info("数据库初始化完成")\n            else:\n                logger.info("数据库表已存在，跳过初始化")\n            return "database_ready"\n        except Exception as e:\n            logger.error(f"数据库初始化失败: {e}")\n            raise\n    \n    @task(task_id='get_job_task')\n    def get_job_task():\n        """获取并锁定一个待处理的测试图像作业"""\n        try:\n            job = get_and_lock_job('IMAGE_TEST')\n            if job:\n                logger.info(f"成功获取作业: ID={job['id']}, 提示词={job['prompt_text']}")\n                return job\n            else:\n                logger.info("没有可用的测试图像作业")\n                return None\n        except Exception as e:\n            logger.error(f"获取作业失败: {e}")\n            raise\n    \n    @task(task_id='generate_image_task')\n    def generate_image_task(job_data, **context):\n        """生成测试图像"""\n        if not job_data:\n            logger.info("跳过图像生成，没有可用作业")\n            return None\n        \n        try:\n            job_id = job_data['id']\n            prompt_text = job_data['prompt_text']\n            \n            # 从DAG参数获取dry_run设置\n            dry_run_value = context['params'].get('dry_run', True)\n            logger.info(f"开始生成图像，作业ID: {job_id}, Dry Run模式: {dry_run_value}")\n            \n            # 创建图像生成器实例\n            image_generator = ImageGenerator()\n            \n            # 生成图像（传递dry_run参数）\n            local_path = image_generator.generate_test_image_and_save(\n                prompt_text, \n                dry_run=dry_run_value\n            )\n            \n            mode_text = "DRY RUN" if dry_run_value else "REAL"\n            logger.info(f"{mode_text}图像生成完成，保存路径: {local_path}")\n            \n            return {\n                'job_id': job_id,\n                'local_path': local_path,\n                'prompt_text': prompt_text,\n                'dry_run': dry_run_value\n            }\n            \n        except Exception as e:\n            logger.error(f"图像生成失败: {e}")\n            # 标记作业为失败\n            if job_data:\n                mark_job_as_failed(job_data['id'], str(e))\n            raise\n    \n    @task(task_id='finalize_job_task')\n    def finalize_job_task(generation_result):\n        """完成作业处理"""\n        if not generation_result:\n            logger.info("跳过作业完成，没有生成结果")\n            return "跳过完成"\n        \n        try:\n            job_id = generation_result['job_id']\n            local_path = generation_result['local_path']\n            dry_run = generation_result.get('dry_run', True)\n            \n            # 标记作业为完成\n            success = mark_job_as_completed(job_id, local_path)\n            \n            if success:\n                mode_text = "DRY RUN" if dry_run else "REAL"\n                logger.info(f"作业 {job_id} 已成功完成 ({mode_text}模式)")\n                return f"作业 {job_id} 完成 ({mode_text}模式)"\n            else:\n                logger.error(f"无法标记作业 {job_id} 为完成")\n                raise Exception(f"无法标记作业 {job_id} 为完成")\n                \n        except Exception as e:\n            logger.error(f"完成作业失败: {e}")\n            raise\n    \n    @task(task_id='cleanup_test_files')\n    def cleanup_test_files():\n        """清理旧的测试文件"""\n        try:\n            image_generator = ImageGenerator()\n            cleaned_count = image_generator.cleanup_test_files(max_age_hours=24)\n            logger.info(f"清理了 {cleaned_count} 个测试文件")\n            return f"清理了 {cleaned_count} 个文件"\n        except Exception as e:\n            logger.error(f"清理测试文件失败: {e}")\n            raise\n    \n    # 定义任务流程\n    init_db = initialize_database()\n    job_data = get_job_task()\n    generation_result = generate_image_task(job_data)\n    finalize_result = finalize_job_task(generation_result)\n    cleanup = cleanup_test_files()\n    \n    # 设置任务依赖\n    init_db >> job_data >> generation_result >> finalize_result\n    cleanup  # 清理任务可以独立运行\n\n# 创建DAG实例\ntest_dag = test_image_generation_dag() 
34617681906255382	/opt/airflow/dags/veo_video_generation_dag.py	2025-07-21 12:47:43.227005+00	"""\n企业级Veo视频生成DAG\n实现健壮的、支持恢复式重试的视频生成工作流\n"""\nfrom datetime import datetime, timedelta\nfrom airflow.decorators import dag, task\nimport logging\nimport sys\nimport os\n\n# 添加src目录到Python路径\nsys.path.append('/opt/airflow/src')\n\nlogger = logging.getLogger(__name__)\n\n@dag(\n    dag_id='veo_video_generation_workflow',\n    description='企业级Veo视频生成工作流',\n    start_date=datetime(2024, 1, 1),\n    schedule=None,  # 手动触发\n    catchup=False,\n    tags=['veo', 'video-generation', 'enterprise'],\n    default_args={\n        'owner': 'ai-team',\n        'depends_on_past': False,\n        'email_on_failure': False,\n        'email_on_retry': False,\n        'retries': 2,\n        'retry_delay': timedelta(minutes=5),\n    }\n)\ndef veo_video_generation_workflow():\n    """企业级视频生成工作流"""\n\n    # 在DAG函数内部导入模块\n    try:\n        from src.core_workflow import (\n            get_and_lock_job, mark_job_as_completed, mark_job_as_failed,\n            update_job_operation_info, mark_job_as_awaiting_retry,\n            get_job_by_id, update_job_gcs_uri\n        )\n        from src.gen_video import submit_veo_generation_task, poll_veo_operation_status\n        from src.database import db_manager\n    except ImportError as e:\n        logger.error(f"导入模块失败: {e}")\n        raise\n\n    @task(task_id='initialize_database')\n    def initialize_database():\n        """初始化数据库连接"""\n        try:\n            # 只在表不存在时初始化\n            if not db_manager.check_table_exists('jobs'):\n                db_manager.init_database()\n                logger.info("数据库初始化完成")\n            else:\n                logger.info("数据库表已存在，跳过初始化")\n            return "database_ready"\n        except Exception as e:\n            logger.error(f"数据库初始化失败: {e}")\n            raise\n\n    @task(task_id='get_job_task')\n    def get_job_task():\n        """获取待处理的VIDEO_PROD作业"""\n        try:\n            job = get_and_lock_job('VIDEO_PROD')\n            if job:\n                logger.info(f"获取到作业: ID={job['id']}, 提示词={job['prompt_text'][:50]}...")\n                return job\n            else:\n                logger.info("没有找到可用的VIDEO_PROD作业")\n                return None\n        except Exception as e:\n            logger.error(f"获取作业失败: {e}")\n            raise\n\n    @task(task_id='submit_job_task')\n    def submit_job_task(job_data):\n        """提交视频生成任务"""\n        if not job_data:\n            logger.info("跳过提交，没有可用作业")\n            return None\n\n        try:\n            job_id = job_data['id']\n            prompt_text = job_data['prompt_text']\n            is_retry = job_data.get('is_retry', False)\n\n            logger.info(f"处理作业 {job_id}，重试模式: {is_retry}")\n            logger.info(f"使用提示词: {prompt_text}")\n\n            if is_retry:\n                # 恢复模式：检查是否已有operation_id\n                job_info = get_job_by_id(job_id)\n                if job_info and job_info.get('operation_id'):\n                    logger.info(f"恢复模式：使用现有operation_id: {job_info['operation_id']}")\n                    return {\n                        'job_id': job_id,\n                        'prompt_text': prompt_text,\n                        'operation_id': job_info['operation_id'],\n                        'mode': 'resume'\n                    }\n                else:\n                    logger.warning("恢复模式但未找到operation_id，转为新提交模式")\n\n            # 新提交模式\n            logger.info("新提交模式：提交视频生成任务")\n            try:\n                operation_id = submit_veo_generation_task(prompt_text)\n\n                # 更新数据库中的operation_id\n                success = update_job_operation_info(job_id, operation_id)\n                if not success:\n                    logger.error(f"无法更新作业 {job_id} 的operation_id")\n                    raise Exception("数据库更新失败")\n\n                logger.info(f"提交成功，operation_id: {operation_id}")\n                return {\n                    'job_id': job_id,\n                    'prompt_text': prompt_text,\n                    'operation_id': operation_id,\n                    'mode': 'submit'\n                }\n\n            except Exception as e:\n                logger.error(f"提交失败: {e}")\n                mark_job_as_failed(job_id, str(e))\n                raise\n\n        except Exception as e:\n            logger.error(f"提交任务失败: {e}")\n            raise\n\n    @task(task_id='poll_job_task', execution_timeout=timedelta(minutes=20))\n    def poll_job_task(submit_result):\n        """轮询视频生成状态（20分钟超时）"""\n        if not submit_result:\n            logger.info("跳过轮询，没有提交结果")\n            return None\n\n        try:\n            job_id = submit_result['job_id']\n            operation_id = submit_result['operation_id']\n            mode = submit_result['mode']\n\n            logger.info(f"开始轮询作业 {job_id}，operation_id: {operation_id}，模式: {mode}")\n\n            try:\n                # 轮询视频生成状态\n                gcs_uri = poll_veo_operation_status(operation_id)\n\n                # 关键要求：重新查询数据库获取最新的gcs_uri\n                logger.info("轮询成功，重新查询数据库确认最新状态")\n\n                # 更新数据库中的GCS URI\n                success = update_job_gcs_uri(job_id, gcs_uri)\n                if success:\n                    # 从数据库重新获取最新信息\n                    updated_job = get_job_by_id(job_id)\n                    if updated_job:\n                        final_gcs_uri = updated_job['gcs_uri']\n                        logger.info(f"从数据库确认最终GCS URI: {final_gcs_uri}")\n\n                        return {\n                            **submit_result,\n                            'status': 'poll_completed',\n                            'gcs_uri': final_gcs_uri\n                        }\n                    else:\n                        logger.error(f"无法从数据库获取作业 {job_id} 的最新信息")\n                        raise Exception("数据库查询失败")\n                else:\n                    logger.error(f"无法更新作业 {job_id} 的GCS URI")\n                    raise Exception("数据库更新失败")\n\n            except Exception as poll_error:\n                # 轮询失败/超时，更新状态为awaiting_manual_retry\n                logger.error(f"轮询失败或超时: {poll_error}")\n                mark_job_as_awaiting_retry(job_id)\n                logger.info(f"作业 {job_id} 已标记为等待手动重试")\n                raise\n\n        except Exception as e:\n            logger.error(f"轮询任务失败: {e}")\n            raise\n\n    @task(task_id='finalize_job_task')\n    def finalize_job_task(poll_result):\n        """完成作业处理"""\n        if not poll_result:\n            logger.info("跳过作业完成，没有轮询结果")\n            return "跳过完成"\n\n        try:\n            job_id = poll_result['job_id']\n            gcs_uri = poll_result['gcs_uri']\n\n            # 标记作业为完成\n            success = mark_job_as_completed(job_id, gcs_uri=gcs_uri)\n\n            if success:\n                logger.info(f"作业 {job_id} 已成功完成，GCS URI: {gcs_uri}")\n                return f"作业 {job_id} 完成"\n            else:\n                # 检查是否已经完成\n                current_job = get_job_by_id(job_id)\n                if current_job and current_job['status'] == 'completed':\n                    logger.info(f"作业 {job_id} 已经处于完成状态")\n                    return f"作业 {job_id} 已完成"\n                else:\n                    logger.error(f"无法标记作业 {job_id} 为完成")\n                    raise Exception(f"无法标记作业 {job_id} 为完成")\n\n        except Exception as e:\n            logger.error(f"完成作业失败: {e}")\n            raise\n\n    # 定义任务流程\n    init_db = initialize_database()\n    job_data = get_job_task()\n    submit_result = submit_job_task(job_data)\n    poll_result = poll_job_task(submit_result)\n    finalize_result = finalize_job_task(poll_result)\n\n    # 设置任务依赖\n    init_db >> job_data >> submit_result >> poll_result >> finalize_result\n\n# 实例化DAG\nveo_video_generation_dag = veo_video_generation_workflow()
\.


--
-- Data for Name: dag_owner_attributes; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dag_owner_attributes (dag_id, owner, link) FROM stdin;
\.


--
-- Data for Name: dag_pickle; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dag_pickle (id, pickle, created_dttm, pickle_hash) FROM stdin;
\.


--
-- Data for Name: dag_run; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dag_run (id, dag_id, queued_at, execution_date, start_date, end_date, state, run_id, creating_job_id, external_trigger, run_type, conf, data_interval_start, data_interval_end, last_scheduling_decision, dag_hash, log_template_id, updated_at, clear_number) FROM stdin;
\.


--
-- Data for Name: dag_run_note; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dag_run_note (user_id, dag_run_id, content, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: dag_schedule_dataset_reference; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dag_schedule_dataset_reference (dataset_id, dag_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: dag_tag; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dag_tag (name, dag_id) FROM stdin;
test	simple_test_workflow
simple	simple_test_workflow
video-generation	veo_video_generation_workflow
veo	veo_video_generation_workflow
enterprise	veo_video_generation_workflow
development	image_generation_test_workflow
test	image_generation_test_workflow
image-generation	image_generation_test_workflow
\.


--
-- Data for Name: dag_warning; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dag_warning (dag_id, warning_type, message, "timestamp") FROM stdin;
\.


--
-- Data for Name: dagrun_dataset_event; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dagrun_dataset_event (dag_run_id, event_id) FROM stdin;
\.


--
-- Data for Name: dataset; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dataset (id, uri, extra, created_at, updated_at, is_orphaned) FROM stdin;
\.


--
-- Data for Name: dataset_dag_run_queue; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dataset_dag_run_queue (dataset_id, target_dag_id, created_at) FROM stdin;
\.


--
-- Data for Name: dataset_event; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.dataset_event (id, dataset_id, extra, source_task_id, source_dag_id, source_run_id, source_map_index, "timestamp") FROM stdin;
\.


--
-- Data for Name: import_error; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.import_error (id, "timestamp", filename, stacktrace, processor_subdir) FROM stdin;
\.


--
-- Data for Name: job; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.job (id, dag_id, state, job_type, start_date, end_date, latest_heartbeat, executor_class, hostname, unixname) FROM stdin;
1	\N	running	SchedulerJob	2025-07-21 12:36:26.125623+00	\N	2025-07-21 12:51:59.085424+00	\N	1a20345a60d1	airflow
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.jobs (id, prompt_text, status, job_type, local_path, gcs_uri, operation_id, created_at, updated_at) FROM stdin;
1	测试PostgreSQL作业	pending	IMAGE_TEST	\N	\N	\N	2025-07-21 12:44:52.47215	2025-07-21 12:44:52.47215
2	第二个测试作业	pending	VIDEO_PROD	\N	\N	\N	2025-07-21 12:45:19.644781	2025-07-21 12:45:19.644781
3	第三个测试作业	pending	IMAGE_TEST	\N	\N	\N	2025-07-21 12:45:19.647132	2025-07-21 12:45:19.647132
\.


--
-- Data for Name: log; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.log (id, dttm, dag_id, task_id, map_index, event, execution_date, run_id, owner, owner_display_name, extra) FROM stdin;
1	2025-07-21 12:36:14.512861+00	\N	\N	\N	cli_check	\N	\N	airflow	\N	{"host_name": "086fbfb872bd", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
2	2025-07-21 12:36:15.522453+00	\N	\N	\N	cli_users_create	\N	\N	airflow	\N	{"host_name": "086fbfb872bd", "full_command": "['/home/airflow/.local/bin/airflow', 'users', 'create', '--username', 'admin', '--firstname', 'Admin', '--lastname', 'User', '--role', 'Admin', '--email', 'admin@example.com', '--password', '********']"}
4	2025-07-21 12:36:23.23181+00	\N	\N	\N	cli_check	\N	\N	airflow	\N	{"host_name": "12c5f63a68ab", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
3	2025-07-21 12:36:23.232134+00	\N	\N	\N	cli_check	\N	\N	airflow	\N	{"host_name": "1a20345a60d1", "full_command": "['/home/airflow/.local/bin/airflow', 'db', 'check']"}
5	2025-07-21 12:36:24.417012+00	\N	\N	\N	cli_webserver	\N	\N	airflow	\N	{"host_name": "12c5f63a68ab", "full_command": "['/home/airflow/.local/bin/airflow', 'webserver']"}
6	2025-07-21 12:36:25.621791+00	\N	\N	\N	cli_scheduler	\N	\N	airflow	\N	{"host_name": "1a20345a60d1", "full_command": "['/home/airflow/.local/bin/airflow', 'scheduler']"}
7	2025-07-21 12:37:23.868346+00	\N	\N	\N	blocked	\N	\N	admin	Admin User	{"dag_ids": "veo_video_generation_workflow"}
8	2025-07-21 12:37:54.652289+00	\N	\N	\N	cli_dag_list_dags	\N	\N	airflow	\N	{"host_name": "1a20345a60d1", "full_command": "['/home/airflow/.local/bin/airflow', 'dags', 'list']"}
9	2025-07-21 12:43:26.448841+00	\N	\N	\N	blocked	\N	\N	admin	Admin User	{"dag_ids": "veo_video_generation_workflow"}
10	2025-07-21 12:46:24.450677+00	\N	\N	\N	blocked	\N	\N	admin	Admin User	{"dag_ids": "veo_video_generation_workflow"}
\.


--
-- Data for Name: log_template; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.log_template (id, filename, elasticsearch_id, created_at) FROM stdin;
1	{{ ti.dag_id }}/{{ ti.task_id }}/{{ ts }}/{{ try_number }}.log	{dag_id}-{task_id}-{execution_date}-{try_number}	2025-07-21 12:36:06.757287+00
2	dag_id={{ ti.dag_id }}/run_id={{ ti.run_id }}/task_id={{ ti.task_id }}/{% if ti.map_index >= 0 %}map_index={{ ti.map_index }}/{% endif %}attempt={{ try_number }}.log	{dag_id}-{task_id}-{run_id}-{map_index}-{try_number}	2025-07-21 12:36:06.757293+00
\.


--
-- Data for Name: rendered_task_instance_fields; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.rendered_task_instance_fields (dag_id, task_id, run_id, map_index, rendered_fields, k8s_pod_yaml) FROM stdin;
\.


--
-- Data for Name: serialized_dag; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.serialized_dag (dag_id, fileloc, fileloc_hash, data, data_compressed, last_updated, dag_hash, processor_subdir) FROM stdin;
download_workflow	/opt/airflow/dags/download_workflow_dag.py	52857970949920226	{"__version": 1, "dag": {"default_args": {"__var": {"owner": "ai-team", "depends_on_past": false, "start_date": {"__var": 1735689600.0, "__type": "datetime"}, "email_on_failure": false, "email_on_retry": false, "retries": 2, "retry_delay": {"__var": 300.0, "__type": "timedelta"}}, "__type": "dict"}, "catchup": false, "timezone": "UTC", "_description": "\\u5f02\\u6b65\\u4e0b\\u8f7d\\u751f\\u6210\\u7684\\u6587\\u4ef6", "fileloc": "/opt/airflow/dags/download_workflow_dag.py", "schedule_interval": {"__var": 300.0, "__type": "timedelta"}, "_task_group": {"_group_id": null, "prefix_group_id": true, "tooltip": "", "ui_color": "CornflowerBlue", "ui_fgcolor": "#000", "children": {"scan_download_queue": ["operator", "scan_download_queue"], "prepare_download_batch": ["operator", "prepare_download_batch"], "download_images": ["operator", "download_images"], "download_videos": ["operator", "download_videos"], "update_download_stats": ["operator", "update_download_stats"], "cleanup_old_records": ["operator", "cleanup_old_records"]}, "upstream_group_ids": [], "downstream_group_ids": [], "upstream_task_ids": [], "downstream_task_ids": []}, "max_active_runs": 1, "_dag_id": "download_workflow", "edge_info": {}, "_processor_dags_folder": "/opt/airflow/dags", "tasks": [{"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1735689600.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "scan_download_queue", "weight_rule": "downstream", "ui_fgcolor": "#000", "params": {"file_type": {"__class": "airflow.models.param.Param", "default": "all", "description": null, "schema": {"__var": {}, "__type": "dict"}}, "max_downloads": {"__class": "airflow.models.param.Param", "default": 10, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "priority_threshold": {"__class": "airflow.models.param.Param", "default": 0, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "force_redownload": {"__class": "airflow.models.param.Param", "default": false, "description": null, "schema": {"__var": {}, "__type": "dict"}}}, "multiple_outputs": true, "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["prepare_download_batch"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u626b\\u63cf\\u4e0b\\u8f7d\\u961f\\u5217\\uff0c\\u83b7\\u53d6\\u5f85\\u4e0b\\u8f7d\\u4efb\\u52a1", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 2, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": [], "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1735689600.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "prepare_download_batch", "weight_rule": "downstream", "ui_fgcolor": "#000", "params": {"file_type": {"__class": "airflow.models.param.Param", "default": "all", "description": null, "schema": {"__var": {}, "__type": "dict"}}, "max_downloads": {"__class": "airflow.models.param.Param", "default": 10, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "priority_threshold": {"__class": "airflow.models.param.Param", "default": 0, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "force_redownload": {"__class": "airflow.models.param.Param", "default": false, "description": null, "schema": {"__var": {}, "__type": "dict"}}}, "multiple_outputs": true, "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["download_images", "download_videos"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u51c6\\u5907\\u4e0b\\u8f7d\\u6279\\u6b21", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 2, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": "(XComArg(<Task(_PythonDecoratedOperator): scan_download_queue>),)", "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1735689600.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "download_images", "weight_rule": "downstream", "ui_fgcolor": "#000", "params": {"file_type": {"__class": "airflow.models.param.Param", "default": "all", "description": null, "schema": {"__var": {}, "__type": "dict"}}, "max_downloads": {"__class": "airflow.models.param.Param", "default": 10, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "priority_threshold": {"__class": "airflow.models.param.Param", "default": 0, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "force_redownload": {"__class": "airflow.models.param.Param", "default": false, "description": null, "schema": {"__var": {}, "__type": "dict"}}}, "multiple_outputs": true, "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["update_download_stats"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u4e0b\\u8f7d\\u56fe\\u50cf\\u6587\\u4ef6", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 2, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": "(XComArg(<Task(_PythonDecoratedOperator): prepare_download_batch>),)", "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1735689600.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "download_videos", "weight_rule": "downstream", "ui_fgcolor": "#000", "params": {"file_type": {"__class": "airflow.models.param.Param", "default": "all", "description": null, "schema": {"__var": {}, "__type": "dict"}}, "max_downloads": {"__class": "airflow.models.param.Param", "default": 10, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "priority_threshold": {"__class": "airflow.models.param.Param", "default": 0, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "force_redownload": {"__class": "airflow.models.param.Param", "default": false, "description": null, "schema": {"__var": {}, "__type": "dict"}}}, "multiple_outputs": true, "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["update_download_stats"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u4e0b\\u8f7d\\u89c6\\u9891\\u6587\\u4ef6", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 2, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": "(XComArg(<Task(_PythonDecoratedOperator): prepare_download_batch>),)", "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1735689600.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "update_download_stats", "weight_rule": "downstream", "ui_fgcolor": "#000", "params": {"file_type": {"__class": "airflow.models.param.Param", "default": "all", "description": null, "schema": {"__var": {}, "__type": "dict"}}, "max_downloads": {"__class": "airflow.models.param.Param", "default": 10, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "priority_threshold": {"__class": "airflow.models.param.Param", "default": 0, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "force_redownload": {"__class": "airflow.models.param.Param", "default": false, "description": null, "schema": {"__var": {}, "__type": "dict"}}}, "multiple_outputs": true, "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["cleanup_old_records"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u66f4\\u65b0\\u4e0b\\u8f7d\\u7edf\\u8ba1\\u4fe1\\u606f", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 2, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": "(XComArg(<Task(_PythonDecoratedOperator): download_images>), XComArg(<Task(_PythonDecoratedOperator): download_videos>))", "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1735689600.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "cleanup_old_records", "weight_rule": "downstream", "ui_fgcolor": "#000", "params": {"file_type": {"__class": "airflow.models.param.Param", "default": "all", "description": null, "schema": {"__var": {}, "__type": "dict"}}, "max_downloads": {"__class": "airflow.models.param.Param", "default": 10, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "priority_threshold": {"__class": "airflow.models.param.Param", "default": 0, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "force_redownload": {"__class": "airflow.models.param.Param", "default": false, "description": null, "schema": {"__var": {}, "__type": "dict"}}}, "multiple_outputs": true, "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": [], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u6e05\\u7406\\u65e7\\u7684\\u4e0b\\u8f7d\\u8bb0\\u5f55", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 2, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": [], "op_kwargs": {}}], "dag_dependencies": [], "params": {"file_type": {"__class": "airflow.models.param.Param", "default": "all", "description": null, "schema": {"__var": {}, "__type": "dict"}}, "max_downloads": {"__class": "airflow.models.param.Param", "default": 10, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "priority_threshold": {"__class": "airflow.models.param.Param", "default": 0, "description": null, "schema": {"__var": {}, "__type": "dict"}}, "force_redownload": {"__class": "airflow.models.param.Param", "default": false, "description": null, "schema": {"__var": {}, "__type": "dict"}}}}}	\N	2025-07-21 12:36:26.373649+00	0cb182a5420aa224eab28745811dd8b3	/opt/airflow/dags
simple_test_workflow	/opt/airflow/dags/simple_test_dag.py	51986830495754876	{"__version": 1, "dag": {"tags": ["test", "simple"], "default_args": {"__var": {"owner": "ai-team", "depends_on_past": false, "start_date": {"__var": 1704067200.0, "__type": "datetime"}, "email_on_failure": false, "email_on_retry": false, "retries": 1, "retry_delay": {"__var": 300.0, "__type": "timedelta"}}, "__type": "dict"}, "catchup": false, "timezone": "UTC", "_description": "\\u7b80\\u5316\\u7684\\u6d4b\\u8bd5\\u5de5\\u4f5c\\u6d41", "_default_view": "grid", "fileloc": "/opt/airflow/dags/simple_test_dag.py", "schedule_interval": null, "_task_group": {"_group_id": null, "prefix_group_id": true, "tooltip": "", "ui_color": "CornflowerBlue", "ui_fgcolor": "#000", "children": {"test_import": ["operator", "test_import"], "test_database": ["operator", "test_database"]}, "upstream_group_ids": [], "downstream_group_ids": [], "upstream_task_ids": [], "downstream_task_ids": []}, "_dag_id": "simple_test_workflow", "edge_info": {}, "doc_md": "\\n    \\u7b80\\u5316\\u7684\\u6d4b\\u8bd5DAG\\n    ", "_processor_dags_folder": "/opt/airflow/dags", "tasks": [{"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1704067200.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "test_import", "weight_rule": "downstream", "ui_fgcolor": "#000", "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["test_database"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u6d4b\\u8bd5\\u6a21\\u5757\\u5bfc\\u5165", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 1, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": [], "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1704067200.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "test_database", "weight_rule": "downstream", "ui_fgcolor": "#000", "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": [], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u6d4b\\u8bd5\\u6570\\u636e\\u5e93\\u8fde\\u63a5", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 1, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": [], "op_kwargs": {}}], "dag_dependencies": [], "params": {}}}	\N	2025-07-21 12:36:26.606328+00	f425050a5a5ee41a646e99b16330dcf8	/opt/airflow/dags
veo_video_generation_workflow	/opt/airflow/dags/veo_video_generation_dag.py	34617681906255382	{"__version": 1, "dag": {"start_date": 1704067200.0, "tags": ["veo", "video-generation", "enterprise"], "default_args": {"__var": {"owner": "ai-team", "depends_on_past": false, "email_on_failure": false, "email_on_retry": false, "retries": 2, "retry_delay": {"__var": 300.0, "__type": "timedelta"}}, "__type": "dict"}, "catchup": false, "timezone": "UTC", "_description": "\\u4f01\\u4e1a\\u7ea7Veo\\u89c6\\u9891\\u751f\\u6210\\u5de5\\u4f5c\\u6d41", "_default_view": "grid", "fileloc": "/opt/airflow/dags/veo_video_generation_dag.py", "schedule_interval": null, "_task_group": {"_group_id": null, "prefix_group_id": true, "tooltip": "", "ui_color": "CornflowerBlue", "ui_fgcolor": "#000", "children": {"initialize_database": ["operator", "initialize_database"], "get_job_task": ["operator", "get_job_task"], "submit_job_task": ["operator", "submit_job_task"], "poll_job_task": ["operator", "poll_job_task"], "finalize_job_task": ["operator", "finalize_job_task"]}, "upstream_group_ids": [], "downstream_group_ids": [], "upstream_task_ids": [], "downstream_task_ids": []}, "_dag_id": "veo_video_generation_workflow", "edge_info": {}, "doc_md": "\\u4f01\\u4e1a\\u7ea7\\u89c6\\u9891\\u751f\\u6210\\u5de5\\u4f5c\\u6d41", "_processor_dags_folder": "/opt/airflow/dags", "tasks": [{"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "initialize_database", "weight_rule": "downstream", "ui_fgcolor": "#000", "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["get_job_task"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u521d\\u59cb\\u5316\\u6570\\u636e\\u5e93\\u8fde\\u63a5", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 2, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": [], "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "get_job_task", "weight_rule": "downstream", "ui_fgcolor": "#000", "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["submit_job_task"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u83b7\\u53d6\\u5f85\\u5904\\u7406\\u7684VIDEO_PROD\\u4f5c\\u4e1a", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 2, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": [], "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "submit_job_task", "weight_rule": "downstream", "ui_fgcolor": "#000", "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["poll_job_task"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u63d0\\u4ea4\\u89c6\\u9891\\u751f\\u6210\\u4efb\\u52a1", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 2, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": "(XComArg(<Task(_PythonDecoratedOperator): get_job_task>),)", "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "execution_timeout": 1200.0, "pool": "default_pool", "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "poll_job_task", "weight_rule": "downstream", "ui_fgcolor": "#000", "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["finalize_job_task"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u8f6e\\u8be2\\u89c6\\u9891\\u751f\\u6210\\u72b6\\u6001\\uff0820\\u5206\\u949f\\u8d85\\u65f6\\uff09", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 2, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": "(XComArg(<Task(_PythonDecoratedOperator): submit_job_task>),)", "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "finalize_job_task", "weight_rule": "downstream", "ui_fgcolor": "#000", "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": [], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u5b8c\\u6210\\u4f5c\\u4e1a\\u5904\\u7406", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 2, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": "(XComArg(<Task(_PythonDecoratedOperator): poll_job_task>),)", "op_kwargs": {}}], "dag_dependencies": [], "params": {}}}	\N	2025-07-21 12:36:27.471534+00	d203d621e185ca9a46f52037f862267b	/opt/airflow/dags
image_generation_test_workflow	/opt/airflow/dags/test_image_generation_dag.py	57622103943375835	{"__version": 1, "dag": {"tags": ["test", "image-generation", "development"], "default_args": {"__var": {"owner": "ai-team", "depends_on_past": false, "start_date": {"__var": 1704067200.0, "__type": "datetime"}, "email_on_failure": false, "email_on_retry": false, "retries": 1, "retry_delay": {"__var": 300.0, "__type": "timedelta"}}, "__type": "dict"}, "catchup": false, "timezone": "UTC", "_description": "\\u6d4b\\u8bd5\\u56fe\\u50cf\\u751f\\u6210\\u5de5\\u4f5c\\u6d41 - \\u4ec5\\u7528\\u4e8e\\u6d4b\\u8bd5\\u76ee\\u7684", "_default_view": "grid", "_max_active_tasks": 1, "fileloc": "/opt/airflow/dags/test_image_generation_dag.py", "schedule_interval": null, "_task_group": {"_group_id": null, "prefix_group_id": true, "tooltip": "", "ui_color": "CornflowerBlue", "ui_fgcolor": "#000", "children": {"initialize_database": ["operator", "initialize_database"], "get_job_task": ["operator", "get_job_task"], "generate_image_task": ["operator", "generate_image_task"], "finalize_job_task": ["operator", "finalize_job_task"], "cleanup_test_files": ["operator", "cleanup_test_files"]}, "upstream_group_ids": [], "downstream_group_ids": [], "upstream_task_ids": [], "downstream_task_ids": []}, "max_active_runs": 1, "_dag_id": "image_generation_test_workflow", "edge_info": {}, "doc_md": "\\n# \\u6d4b\\u8bd5\\u56fe\\u50cf\\u751f\\u6210\\u5de5\\u4f5c\\u6d41\\n\\n## \\u26a0\\ufe0f \\u91cd\\u8981\\u8b66\\u544a \\u26a0\\ufe0f\\n\\n**\\u6b64DAG\\u4ec5\\u7528\\u4e8e\\u6d4b\\u8bd5\\u76ee\\u7684\\uff01**\\n\\n### \\u4f7f\\u7528\\u8bf4\\u660e\\uff1a\\n- \\u6b64DAG\\u4f7f\\u7528\\u4f4e\\u6210\\u672c\\u7684\\u6587\\u672c\\u5230\\u56fe\\u50cf\\u6a21\\u578b\\n- \\u751f\\u6210\\u7684\\u6587\\u4ef6\\u4f1a\\u81ea\\u52a8\\u6807\\u8bb0\\u4e3a\\u6d4b\\u8bd5\\u6570\\u636e\\uff08\\u6587\\u4ef6\\u540d\\u5305\\u542b`_image_test`\\uff09\\n- \\u751f\\u6210\\u7684\\u6570\\u636e\\u8d28\\u91cf\\u53ef\\u80fd\\u8f83\\u4f4e\\uff0c\\u4ec5\\u7528\\u4e8e\\u9a8c\\u8bc1\\u5de5\\u4f5c\\u6d41\\u7a0b\\n- \\u8bf7\\u52ff\\u5728\\u751f\\u4ea7\\u73af\\u5883\\u4e2d\\u4f7f\\u7528\\u6b64DAG\\n\\n### Dry Run\\u6a21\\u5f0f\\uff08\\u9ed8\\u8ba4\\uff09\\uff1a\\n- **\\u9ed8\\u8ba4\\u542f\\u7528**\\uff1aDry Run\\u6a21\\u5f0f\\u9ed8\\u8ba4\\u5f00\\u542f\\uff0c\\u786e\\u4fdd\\u96f6API\\u6210\\u672c\\n- **\\u5360\\u4f4d\\u7b26\\u6587\\u4ef6**\\uff1a\\u521b\\u5efa`.txt`\\u5360\\u4f4d\\u7b26\\u6587\\u4ef6\\u800c\\u4e0d\\u662f\\u771f\\u5b9e\\u56fe\\u50cf\\n- **\\u5b8c\\u6574\\u6d4b\\u8bd5**\\uff1a\\u9a8c\\u8bc1\\u6240\\u6709\\u6570\\u636e\\u5e93\\u64cd\\u4f5c\\u3001\\u4efb\\u52a1\\u4f9d\\u8d56\\u548c\\u6587\\u4ef6I/O\\n- **\\u5b89\\u5168\\u7b2c\\u4e00**\\uff1a\\u9632\\u6b62\\u610f\\u5916API\\u8c03\\u7528\\u548c\\u6210\\u672c\\u4ea7\\u751f\\n\\n### \\u771f\\u5b9e\\u6a21\\u5f0f\\uff1a\\n- \\u624b\\u52a8\\u5173\\u95edDry Run\\u5f00\\u5173\\u4ee5\\u542f\\u7528\\u771f\\u5b9eAPI\\u8c03\\u7528\\n- \\u751f\\u6210\\u771f\\u5b9e\\u7684`.png`\\u56fe\\u50cf\\u6587\\u4ef6\\n- \\u4f1a\\u4ea7\\u751fGoogle Vertex AI API\\u6210\\u672c\\n- \\u4ec5\\u7528\\u4e8e\\u6700\\u7ec8\\u6d4b\\u8bd5\\u548c\\u9a8c\\u8bc1\\n\\n### \\u5de5\\u4f5c\\u6d41\\u7a0b\\uff1a\\n1. \\u4ece\\u6570\\u636e\\u5e93\\u83b7\\u53d6\\u5f85\\u5904\\u7406\\u7684IMAGE_TEST\\u7c7b\\u578b\\u4f5c\\u4e1a\\n2. \\u6839\\u636eDry Run\\u8bbe\\u7f6e\\u51b3\\u5b9a\\u662f\\u5426\\u8c03\\u7528API\\n3. \\u4fdd\\u5b58\\u56fe\\u50cf\\u6216\\u5360\\u4f4d\\u7b26\\u6587\\u4ef6\\u5230\\u672c\\u5730outputs\\u76ee\\u5f55\\n4. \\u66f4\\u65b0\\u4f5c\\u4e1a\\u72b6\\u6001\\u4e3a\\u5b8c\\u6210\\n\\n### \\u6e05\\u7406\\uff1a\\n- \\u6d4b\\u8bd5\\u6587\\u4ef6\\u4f1a\\u572824\\u5c0f\\u65f6\\u540e\\u81ea\\u52a8\\u6e05\\u7406\\n- \\u53ef\\u4ee5\\u901a\\u8fc7\\u624b\\u52a8\\u89e6\\u53d1\\u6e05\\u7406\\u4efb\\u52a1\\u6765\\u7acb\\u5373\\u6e05\\u7406\\u65e7\\u6587\\u4ef6\\n\\n### \\u6ce8\\u610f\\u4e8b\\u9879\\uff1a\\n- \\u786e\\u4fddGoogle Cloud\\u51ed\\u636e\\u5df2\\u6b63\\u786e\\u914d\\u7f6e\\n- \\u786e\\u4fdd\\u6570\\u636e\\u5e93\\u8fde\\u63a5\\u6b63\\u5e38\\n- \\u76d1\\u63a7\\u751f\\u6210\\u7684\\u6587\\u4ef6\\u5927\\u5c0f\\u548c\\u5b58\\u50a8\\u7a7a\\u95f4\\n- **\\u91cd\\u8981**\\uff1aDry Run\\u6a21\\u5f0f\\u9ed8\\u8ba4\\u5f00\\u542f\\uff0c\\u786e\\u4fdd\\u6d4b\\u8bd5\\u5b89\\u5168", "_processor_dags_folder": "/opt/airflow/dags", "tasks": [{"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1704067200.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "initialize_database", "weight_rule": "downstream", "ui_fgcolor": "#000", "params": {"dry_run": {"__class": "airflow.models.param.Param", "default": {"__var": {"type": "boolean", "default": false, "title": "Dry Run Mode", "description": "If True, skips the actual API call and creates a placeholder file. Set to False for real API calls."}, "__type": "dict"}, "description": null, "schema": {"__var": {}, "__type": "dict"}}}, "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["get_job_task"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u521d\\u59cb\\u5316\\u6570\\u636e\\u5e93\\u8fde\\u63a5", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 1, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": [], "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1704067200.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "get_job_task", "weight_rule": "downstream", "ui_fgcolor": "#000", "params": {"dry_run": {"__class": "airflow.models.param.Param", "default": {"__var": {"type": "boolean", "default": false, "title": "Dry Run Mode", "description": "If True, skips the actual API call and creates a placeholder file. Set to False for real API calls."}, "__type": "dict"}, "description": null, "schema": {"__var": {}, "__type": "dict"}}}, "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["generate_image_task"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u83b7\\u53d6\\u5e76\\u9501\\u5b9a\\u4e00\\u4e2a\\u5f85\\u5904\\u7406\\u7684\\u6d4b\\u8bd5\\u56fe\\u50cf\\u4f5c\\u4e1a", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 1, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": [], "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1704067200.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "generate_image_task", "weight_rule": "downstream", "ui_fgcolor": "#000", "params": {"dry_run": {"__class": "airflow.models.param.Param", "default": {"__var": {"type": "boolean", "default": false, "title": "Dry Run Mode", "description": "If True, skips the actual API call and creates a placeholder file. Set to False for real API calls."}, "__type": "dict"}, "description": null, "schema": {"__var": {}, "__type": "dict"}}}, "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": ["finalize_job_task"], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u751f\\u6210\\u6d4b\\u8bd5\\u56fe\\u50cf", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 1, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": "(XComArg(<Task(_PythonDecoratedOperator): get_job_task>),)", "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1704067200.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "finalize_job_task", "weight_rule": "downstream", "ui_fgcolor": "#000", "params": {"dry_run": {"__class": "airflow.models.param.Param", "default": {"__var": {"type": "boolean", "default": false, "title": "Dry Run Mode", "description": "If True, skips the actual API call and creates a placeholder file. Set to False for real API calls."}, "__type": "dict"}, "description": null, "schema": {"__var": {}, "__type": "dict"}}}, "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": [], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u5b8c\\u6210\\u4f5c\\u4e1a\\u5904\\u7406", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 1, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": "(XComArg(<Task(_PythonDecoratedOperator): generate_image_task>),)", "op_kwargs": {}}, {"owner": "ai-team", "ui_color": "#ffefeb", "template_ext": [], "pool": "default_pool", "start_date": 1704067200.0, "email_on_failure": false, "retry_delay": 300.0, "is_setup": false, "is_teardown": false, "task_id": "cleanup_test_files", "weight_rule": "downstream", "ui_fgcolor": "#000", "params": {"dry_run": {"__class": "airflow.models.param.Param", "default": {"__var": {"type": "boolean", "default": false, "title": "Dry Run Mode", "description": "If True, skips the actual API call and creates a placeholder file. Set to False for real API calls."}, "__type": "dict"}, "description": null, "schema": {"__var": {}, "__type": "dict"}}}, "on_failure_fail_dagrun": false, "template_fields": ["templates_dict", "op_args", "op_kwargs"], "downstream_task_ids": [], "email_on_retry": false, "_log_config_logger_name": "airflow.task.operators", "doc_md": "\\u6e05\\u7406\\u65e7\\u7684\\u6d4b\\u8bd5\\u6587\\u4ef6", "template_fields_renderers": {"templates_dict": "json", "op_args": "py", "op_kwargs": "py"}, "retries": 1, "_task_type": "_PythonDecoratedOperator", "_task_module": "airflow.decorators.python", "_operator_name": "@task", "_is_empty": false, "op_args": [], "op_kwargs": {}}], "dag_dependencies": [], "params": {"dry_run": {"__class": "airflow.models.param.Param", "default": {"__var": {"type": "boolean", "default": false, "title": "Dry Run Mode", "description": "If True, skips the actual API call and creates a placeholder file. Set to False for real API calls."}, "__type": "dict"}, "description": null, "schema": {"__var": {}, "__type": "dict"}}}}}	\N	2025-07-21 12:47:37.106969+00	fe778690dccc044bde1d3d43d7a68bae	/opt/airflow/dags
\.


--
-- Data for Name: session; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.session (id, session_id, data, expiry) FROM stdin;
1	67d0094f-81ab-41c5-a2b7-d453ef4e64fc	\\x80049563000000000000007d94288c0a5f7065726d616e656e7494888c065f667265736894898c0a637372665f746f6b656e948c2834393163653735373830383265303766303832616539303335396238656334396233383033346262948c066c6f63616c65948c02656e94752e	2025-08-20 12:37:20.155037
3	2e623525-af02-433d-ae8b-304b24fd9085	\\x8004951d000000000000007d94288c0a5f7065726d616e656e7494888c065f66726573689489752e	2025-08-20 12:37:47.54719
2	ff204850-ccca-477a-a25d-62c25fa878dc	\\x80049513010000000000007d94288c0a5f7065726d616e656e7494888c065f667265736894888c0a637372665f746f6b656e948c2834393163653735373830383265303766303832616539303335396238656334396233383033346262948c066c6f63616c65948c02656e948c085f757365725f6964944b018c035f6964948c806665366564653134656339613835366631643266313162366631393135313437393062613361333961353861383162383865383836303531366264383533346466626361343964316632363132343763653966316238633230623062363665353561643361303336633037626364643130613032386330613930316639333037948c116461675f7374617475735f66696c746572948c03616c6c94752e	2025-08-20 12:46:24.463144
\.


--
-- Data for Name: sla_miss; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.sla_miss (task_id, dag_id, execution_date, email_sent, "timestamp", description, notification_sent) FROM stdin;
\.


--
-- Data for Name: slot_pool; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.slot_pool (id, pool, slots, description, include_deferred) FROM stdin;
1	default_pool	128	Default pool	f
\.


--
-- Data for Name: task_fail; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.task_fail (id, task_id, dag_id, run_id, map_index, start_date, end_date, duration) FROM stdin;
\.


--
-- Data for Name: task_instance; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.task_instance (task_id, dag_id, run_id, map_index, start_date, end_date, duration, state, try_number, max_tries, hostname, unixname, job_id, pool, pool_slots, queue, priority_weight, operator, custom_operator_name, queued_dttm, queued_by_job_id, pid, executor_config, updated_at, rendered_map_index, external_executor_id, trigger_id, trigger_timeout, next_method, next_kwargs, task_display_name) FROM stdin;
\.


--
-- Data for Name: task_instance_note; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.task_instance_note (user_id, task_id, dag_id, run_id, map_index, content, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: task_map; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.task_map (dag_id, task_id, run_id, map_index, length, keys) FROM stdin;
\.


--
-- Data for Name: task_outlet_dataset_reference; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.task_outlet_dataset_reference (dataset_id, dag_id, task_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: task_reschedule; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.task_reschedule (id, task_id, dag_id, run_id, map_index, try_number, start_date, end_date, duration, reschedule_date) FROM stdin;
\.


--
-- Data for Name: trigger; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.trigger (id, classpath, kwargs, created_date, triggerer_id) FROM stdin;
\.


--
-- Data for Name: variable; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.variable (id, key, val, description, is_encrypted) FROM stdin;
\.


--
-- Data for Name: xcom; Type: TABLE DATA; Schema: public; Owner: airflow
--

COPY public.xcom (dag_run_id, task_id, map_index, key, dag_id, run_id, value, "timestamp") FROM stdin;
\.


--
-- Name: ab_permission_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.ab_permission_id_seq', 5, true);


--
-- Name: ab_permission_view_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.ab_permission_view_id_seq', 104, true);


--
-- Name: ab_permission_view_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.ab_permission_view_role_id_seq', 224, true);


--
-- Name: ab_register_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.ab_register_user_id_seq', 1, false);


--
-- Name: ab_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.ab_role_id_seq', 5, true);


--
-- Name: ab_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.ab_user_id_seq', 1, true);


--
-- Name: ab_user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.ab_user_role_id_seq', 1, true);


--
-- Name: ab_view_menu_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.ab_view_menu_id_seq', 57, true);


--
-- Name: callback_request_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.callback_request_id_seq', 1, false);


--
-- Name: connection_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.connection_id_seq', 59, true);


--
-- Name: dag_pickle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.dag_pickle_id_seq', 1, false);


--
-- Name: dag_run_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.dag_run_id_seq', 1, false);


--
-- Name: dataset_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.dataset_event_id_seq', 1, false);


--
-- Name: dataset_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.dataset_id_seq', 1, false);


--
-- Name: import_error_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.import_error_id_seq', 1, false);


--
-- Name: job_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.job_id_seq', 1, true);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.jobs_id_seq', 3, true);


--
-- Name: log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.log_id_seq', 10, true);


--
-- Name: log_template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.log_template_id_seq', 2, true);


--
-- Name: session_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.session_id_seq', 3, true);


--
-- Name: slot_pool_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.slot_pool_id_seq', 1, true);


--
-- Name: task_fail_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.task_fail_id_seq', 1, false);


--
-- Name: task_reschedule_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.task_reschedule_id_seq', 1, false);


--
-- Name: trigger_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.trigger_id_seq', 1, false);


--
-- Name: variable_id_seq; Type: SEQUENCE SET; Schema: public; Owner: airflow
--

SELECT pg_catalog.setval('public.variable_id_seq', 1, false);


--
-- Name: ab_permission ab_permission_name_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_name_uq UNIQUE (name);


--
-- Name: ab_permission ab_permission_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission
    ADD CONSTRAINT ab_permission_pkey PRIMARY KEY (id);


--
-- Name: ab_permission_view ab_permission_view_permission_id_view_menu_id_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_view_menu_id_uq UNIQUE (permission_id, view_menu_id);


--
-- Name: ab_permission_view ab_permission_view_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_pkey PRIMARY KEY (id);


--
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_role_id_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_role_id_uq UNIQUE (permission_view_id, role_id);


--
-- Name: ab_permission_view_role ab_permission_view_role_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_pkey PRIMARY KEY (id);


--
-- Name: ab_register_user ab_register_user_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_pkey PRIMARY KEY (id);


--
-- Name: ab_register_user ab_register_user_username_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_register_user
    ADD CONSTRAINT ab_register_user_username_uq UNIQUE (username);


--
-- Name: ab_role ab_role_name_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_name_uq UNIQUE (name);


--
-- Name: ab_role ab_role_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_role
    ADD CONSTRAINT ab_role_pkey PRIMARY KEY (id);


--
-- Name: ab_user ab_user_email_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_email_uq UNIQUE (email);


--
-- Name: ab_user ab_user_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_pkey PRIMARY KEY (id);


--
-- Name: ab_user_role ab_user_role_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_pkey PRIMARY KEY (id);


--
-- Name: ab_user_role ab_user_role_user_id_role_id_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_role_id_uq UNIQUE (user_id, role_id);


--
-- Name: ab_user ab_user_username_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_username_uq UNIQUE (username);


--
-- Name: ab_view_menu ab_view_menu_name_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_name_uq UNIQUE (name);


--
-- Name: ab_view_menu ab_view_menu_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_view_menu
    ADD CONSTRAINT ab_view_menu_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: callback_request callback_request_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.callback_request
    ADD CONSTRAINT callback_request_pkey PRIMARY KEY (id);


--
-- Name: connection connection_conn_id_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.connection
    ADD CONSTRAINT connection_conn_id_uq UNIQUE (conn_id);


--
-- Name: connection connection_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.connection
    ADD CONSTRAINT connection_pkey PRIMARY KEY (id);


--
-- Name: dag_code dag_code_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_code
    ADD CONSTRAINT dag_code_pkey PRIMARY KEY (fileloc_hash);


--
-- Name: dag_owner_attributes dag_owner_attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_owner_attributes
    ADD CONSTRAINT dag_owner_attributes_pkey PRIMARY KEY (dag_id, owner);


--
-- Name: dag_pickle dag_pickle_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_pickle
    ADD CONSTRAINT dag_pickle_pkey PRIMARY KEY (id);


--
-- Name: dag dag_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag
    ADD CONSTRAINT dag_pkey PRIMARY KEY (dag_id);


--
-- Name: dag_run dag_run_dag_id_execution_date_key; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT dag_run_dag_id_execution_date_key UNIQUE (dag_id, execution_date);


--
-- Name: dag_run dag_run_dag_id_run_id_key; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT dag_run_dag_id_run_id_key UNIQUE (dag_id, run_id);


--
-- Name: dag_run_note dag_run_note_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_run_note
    ADD CONSTRAINT dag_run_note_pkey PRIMARY KEY (dag_run_id);


--
-- Name: dag_run dag_run_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT dag_run_pkey PRIMARY KEY (id);


--
-- Name: dag_tag dag_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_tag
    ADD CONSTRAINT dag_tag_pkey PRIMARY KEY (name, dag_id);


--
-- Name: dag_warning dag_warning_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_warning
    ADD CONSTRAINT dag_warning_pkey PRIMARY KEY (dag_id, warning_type);


--
-- Name: dagrun_dataset_event dagrun_dataset_event_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dagrun_dataset_event
    ADD CONSTRAINT dagrun_dataset_event_pkey PRIMARY KEY (dag_run_id, event_id);


--
-- Name: dataset_event dataset_event_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dataset_event
    ADD CONSTRAINT dataset_event_pkey PRIMARY KEY (id);


--
-- Name: dataset dataset_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (id);


--
-- Name: dataset_dag_run_queue datasetdagrunqueue_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dataset_dag_run_queue
    ADD CONSTRAINT datasetdagrunqueue_pkey PRIMARY KEY (dataset_id, target_dag_id);


--
-- Name: dag_schedule_dataset_reference dsdr_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_schedule_dataset_reference
    ADD CONSTRAINT dsdr_pkey PRIMARY KEY (dataset_id, dag_id);


--
-- Name: import_error import_error_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.import_error
    ADD CONSTRAINT import_error_pkey PRIMARY KEY (id);


--
-- Name: job job_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.job
    ADD CONSTRAINT job_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_prompt_text_key; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_prompt_text_key UNIQUE (prompt_text);


--
-- Name: log log_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_pkey PRIMARY KEY (id);


--
-- Name: log_template log_template_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.log_template
    ADD CONSTRAINT log_template_pkey PRIMARY KEY (id);


--
-- Name: rendered_task_instance_fields rendered_task_instance_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.rendered_task_instance_fields
    ADD CONSTRAINT rendered_task_instance_fields_pkey PRIMARY KEY (dag_id, task_id, run_id, map_index);


--
-- Name: serialized_dag serialized_dag_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.serialized_dag
    ADD CONSTRAINT serialized_dag_pkey PRIMARY KEY (dag_id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (id);


--
-- Name: session session_session_id_key; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_session_id_key UNIQUE (session_id);


--
-- Name: sla_miss sla_miss_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.sla_miss
    ADD CONSTRAINT sla_miss_pkey PRIMARY KEY (task_id, dag_id, execution_date);


--
-- Name: slot_pool slot_pool_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.slot_pool
    ADD CONSTRAINT slot_pool_pkey PRIMARY KEY (id);


--
-- Name: slot_pool slot_pool_pool_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.slot_pool
    ADD CONSTRAINT slot_pool_pool_uq UNIQUE (pool);


--
-- Name: task_fail task_fail_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_fail
    ADD CONSTRAINT task_fail_pkey PRIMARY KEY (id);


--
-- Name: task_instance_note task_instance_note_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_instance_note
    ADD CONSTRAINT task_instance_note_pkey PRIMARY KEY (task_id, dag_id, run_id, map_index);


--
-- Name: task_instance task_instance_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_instance
    ADD CONSTRAINT task_instance_pkey PRIMARY KEY (dag_id, task_id, run_id, map_index);


--
-- Name: task_map task_map_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_map
    ADD CONSTRAINT task_map_pkey PRIMARY KEY (dag_id, task_id, run_id, map_index);


--
-- Name: task_reschedule task_reschedule_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_reschedule
    ADD CONSTRAINT task_reschedule_pkey PRIMARY KEY (id);


--
-- Name: task_outlet_dataset_reference todr_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_outlet_dataset_reference
    ADD CONSTRAINT todr_pkey PRIMARY KEY (dataset_id, dag_id, task_id);


--
-- Name: trigger trigger_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.trigger
    ADD CONSTRAINT trigger_pkey PRIMARY KEY (id);


--
-- Name: variable variable_key_uq; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.variable
    ADD CONSTRAINT variable_key_uq UNIQUE (key);


--
-- Name: variable variable_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.variable
    ADD CONSTRAINT variable_pkey PRIMARY KEY (id);


--
-- Name: xcom xcom_pkey; Type: CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.xcom
    ADD CONSTRAINT xcom_pkey PRIMARY KEY (dag_run_id, task_id, map_index, key);


--
-- Name: dag_id_state; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX dag_id_state ON public.dag_run USING btree (dag_id, state);


--
-- Name: idx_ab_register_user_username; Type: INDEX; Schema: public; Owner: airflow
--

CREATE UNIQUE INDEX idx_ab_register_user_username ON public.ab_register_user USING btree (lower((username)::text));


--
-- Name: idx_ab_user_username; Type: INDEX; Schema: public; Owner: airflow
--

CREATE UNIQUE INDEX idx_ab_user_username ON public.ab_user USING btree (lower((username)::text));


--
-- Name: idx_dag_run_dag_id; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_dag_run_dag_id ON public.dag_run USING btree (dag_id);


--
-- Name: idx_dag_run_queued_dags; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_dag_run_queued_dags ON public.dag_run USING btree (state, dag_id) WHERE ((state)::text = 'queued'::text);


--
-- Name: idx_dag_run_running_dags; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_dag_run_running_dags ON public.dag_run USING btree (state, dag_id) WHERE ((state)::text = 'running'::text);


--
-- Name: idx_dagrun_dataset_events_dag_run_id; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_dagrun_dataset_events_dag_run_id ON public.dagrun_dataset_event USING btree (dag_run_id);


--
-- Name: idx_dagrun_dataset_events_event_id; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_dagrun_dataset_events_event_id ON public.dagrun_dataset_event USING btree (event_id);


--
-- Name: idx_dataset_id_timestamp; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_dataset_id_timestamp ON public.dataset_event USING btree (dataset_id, "timestamp");


--
-- Name: idx_fileloc_hash; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_fileloc_hash ON public.serialized_dag USING btree (fileloc_hash);


--
-- Name: idx_job_dag_id; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_job_dag_id ON public.job USING btree (dag_id);


--
-- Name: idx_job_state_heartbeat; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_job_state_heartbeat ON public.job USING btree (state, latest_heartbeat);


--
-- Name: idx_jobs_created_at; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_jobs_created_at ON public.jobs USING btree (created_at);


--
-- Name: idx_jobs_job_type; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_jobs_job_type ON public.jobs USING btree (job_type);


--
-- Name: idx_jobs_operation_id; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_jobs_operation_id ON public.jobs USING btree (operation_id);


--
-- Name: idx_jobs_status; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_jobs_status ON public.jobs USING btree (status);


--
-- Name: idx_log_dag; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_log_dag ON public.log USING btree (dag_id);


--
-- Name: idx_log_dttm; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_log_dttm ON public.log USING btree (dttm);


--
-- Name: idx_log_event; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_log_event ON public.log USING btree (event);


--
-- Name: idx_next_dagrun_create_after; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_next_dagrun_create_after ON public.dag USING btree (next_dagrun_create_after);


--
-- Name: idx_root_dag_id; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_root_dag_id ON public.dag USING btree (root_dag_id);


--
-- Name: idx_task_fail_task_instance; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_task_fail_task_instance ON public.task_fail USING btree (dag_id, task_id, run_id, map_index);


--
-- Name: idx_task_reschedule_dag_run; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_task_reschedule_dag_run ON public.task_reschedule USING btree (dag_id, run_id);


--
-- Name: idx_task_reschedule_dag_task_run; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_task_reschedule_dag_task_run ON public.task_reschedule USING btree (dag_id, task_id, run_id, map_index);


--
-- Name: idx_uri_unique; Type: INDEX; Schema: public; Owner: airflow
--

CREATE UNIQUE INDEX idx_uri_unique ON public.dataset USING btree (uri);


--
-- Name: idx_xcom_key; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_xcom_key ON public.xcom USING btree (key);


--
-- Name: idx_xcom_task_instance; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX idx_xcom_task_instance ON public.xcom USING btree (dag_id, task_id, run_id, map_index);


--
-- Name: job_type_heart; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX job_type_heart ON public.job USING btree (job_type, latest_heartbeat);


--
-- Name: sm_dag; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX sm_dag ON public.sla_miss USING btree (dag_id);


--
-- Name: ti_dag_run; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX ti_dag_run ON public.task_instance USING btree (dag_id, run_id);


--
-- Name: ti_dag_state; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX ti_dag_state ON public.task_instance USING btree (dag_id, state);


--
-- Name: ti_job_id; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX ti_job_id ON public.task_instance USING btree (job_id);


--
-- Name: ti_pool; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX ti_pool ON public.task_instance USING btree (pool, state, priority_weight);


--
-- Name: ti_state; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX ti_state ON public.task_instance USING btree (state);


--
-- Name: ti_state_lkp; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX ti_state_lkp ON public.task_instance USING btree (dag_id, task_id, run_id, state);


--
-- Name: ti_trigger_id; Type: INDEX; Schema: public; Owner: airflow
--

CREATE INDEX ti_trigger_id ON public.task_instance USING btree (trigger_id);


--
-- Name: jobs update_jobs_updated_at; Type: TRIGGER; Schema: public; Owner: airflow
--

CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON public.jobs FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: ab_permission_view ab_permission_view_permission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.ab_permission(id);


--
-- Name: ab_permission_view_role ab_permission_view_role_permission_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_permission_view_id_fkey FOREIGN KEY (permission_view_id) REFERENCES public.ab_permission_view(id);


--
-- Name: ab_permission_view_role ab_permission_view_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission_view_role
    ADD CONSTRAINT ab_permission_view_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- Name: ab_permission_view ab_permission_view_view_menu_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_permission_view
    ADD CONSTRAINT ab_permission_view_view_menu_id_fkey FOREIGN KEY (view_menu_id) REFERENCES public.ab_view_menu(id);


--
-- Name: ab_user ab_user_changed_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_changed_by_fk_fkey FOREIGN KEY (changed_by_fk) REFERENCES public.ab_user(id);


--
-- Name: ab_user ab_user_created_by_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_user
    ADD CONSTRAINT ab_user_created_by_fk_fkey FOREIGN KEY (created_by_fk) REFERENCES public.ab_user(id);


--
-- Name: ab_user_role ab_user_role_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.ab_role(id);


--
-- Name: ab_user_role ab_user_role_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.ab_user_role
    ADD CONSTRAINT ab_user_role_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- Name: dag_owner_attributes dag.dag_id; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_owner_attributes
    ADD CONSTRAINT "dag.dag_id" FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dag_run_note dag_run_note_dr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_run_note
    ADD CONSTRAINT dag_run_note_dr_fkey FOREIGN KEY (dag_run_id) REFERENCES public.dag_run(id) ON DELETE CASCADE;


--
-- Name: dag_run_note dag_run_note_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_run_note
    ADD CONSTRAINT dag_run_note_user_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- Name: dag_tag dag_tag_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_tag
    ADD CONSTRAINT dag_tag_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dagrun_dataset_event dagrun_dataset_event_dag_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dagrun_dataset_event
    ADD CONSTRAINT dagrun_dataset_event_dag_run_id_fkey FOREIGN KEY (dag_run_id) REFERENCES public.dag_run(id) ON DELETE CASCADE;


--
-- Name: dagrun_dataset_event dagrun_dataset_event_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dagrun_dataset_event
    ADD CONSTRAINT dagrun_dataset_event_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.dataset_event(id) ON DELETE CASCADE;


--
-- Name: dag_warning dcw_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_warning
    ADD CONSTRAINT dcw_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dataset_dag_run_queue ddrq_dag_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dataset_dag_run_queue
    ADD CONSTRAINT ddrq_dag_fkey FOREIGN KEY (target_dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dataset_dag_run_queue ddrq_dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dataset_dag_run_queue
    ADD CONSTRAINT ddrq_dataset_fkey FOREIGN KEY (dataset_id) REFERENCES public.dataset(id) ON DELETE CASCADE;


--
-- Name: dag_schedule_dataset_reference dsdr_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_schedule_dataset_reference
    ADD CONSTRAINT dsdr_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: dag_schedule_dataset_reference dsdr_dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_schedule_dataset_reference
    ADD CONSTRAINT dsdr_dataset_fkey FOREIGN KEY (dataset_id) REFERENCES public.dataset(id) ON DELETE CASCADE;


--
-- Name: rendered_task_instance_fields rtif_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.rendered_task_instance_fields
    ADD CONSTRAINT rtif_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_fail task_fail_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_fail
    ADD CONSTRAINT task_fail_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_instance task_instance_dag_run_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_instance
    ADD CONSTRAINT task_instance_dag_run_fkey FOREIGN KEY (dag_id, run_id) REFERENCES public.dag_run(dag_id, run_id) ON DELETE CASCADE;


--
-- Name: dag_run task_instance_log_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.dag_run
    ADD CONSTRAINT task_instance_log_template_id_fkey FOREIGN KEY (log_template_id) REFERENCES public.log_template(id);


--
-- Name: task_instance_note task_instance_note_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_instance_note
    ADD CONSTRAINT task_instance_note_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_instance_note task_instance_note_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_instance_note
    ADD CONSTRAINT task_instance_note_user_fkey FOREIGN KEY (user_id) REFERENCES public.ab_user(id);


--
-- Name: task_instance task_instance_trigger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_instance
    ADD CONSTRAINT task_instance_trigger_id_fkey FOREIGN KEY (trigger_id) REFERENCES public.trigger(id) ON DELETE CASCADE;


--
-- Name: task_map task_map_task_instance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_map
    ADD CONSTRAINT task_map_task_instance_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: task_reschedule task_reschedule_dr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_reschedule
    ADD CONSTRAINT task_reschedule_dr_fkey FOREIGN KEY (dag_id, run_id) REFERENCES public.dag_run(dag_id, run_id) ON DELETE CASCADE;


--
-- Name: task_reschedule task_reschedule_ti_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_reschedule
    ADD CONSTRAINT task_reschedule_ti_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- Name: task_outlet_dataset_reference todr_dag_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_outlet_dataset_reference
    ADD CONSTRAINT todr_dag_id_fkey FOREIGN KEY (dag_id) REFERENCES public.dag(dag_id) ON DELETE CASCADE;


--
-- Name: task_outlet_dataset_reference todr_dataset_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.task_outlet_dataset_reference
    ADD CONSTRAINT todr_dataset_fkey FOREIGN KEY (dataset_id) REFERENCES public.dataset(id) ON DELETE CASCADE;


--
-- Name: xcom xcom_task_instance_fkey; Type: FK CONSTRAINT; Schema: public; Owner: airflow
--

ALTER TABLE ONLY public.xcom
    ADD CONSTRAINT xcom_task_instance_fkey FOREIGN KEY (dag_id, task_id, run_id, map_index) REFERENCES public.task_instance(dag_id, task_id, run_id, map_index) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

