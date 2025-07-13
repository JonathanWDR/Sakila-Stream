SET search_path TO sakila;

DROP VIEW IF EXISTS customer_list;
DROP VIEW IF EXISTS film_list;
DROP VIEW IF EXISTS sales_by_film_category;
DROP VIEW IF EXISTS v_customer_fav_cat;
DROP VIEW IF EXISTS sales_by_store;


ALTER TABLE CUSTOMER
ADD COLUMN activation_date DATE,
ADD COLUMN birthdate DATE;


ALTER TABLE actor
ADD COLUMN imdb_name_key VARCHAR(15);

ALTER TABLE actor
ALTER column actor_id TYPE INTEGER;


CREATE TABLE content_type (
  content_type_id SMALLINT    NOT NULL,
  content_ty_name VARCHAR(64) NOT NULL,
  additional_info VARCHAR(255),
  CONSTRAINT pk_content_type PRIMARY KEY (content_type_id)
);


CREATE TABLE content_stream (
  content_id             INTEGER        PRIMARY KEY,
  content_type_id        SMALLINT      NOT NULL,
  title                  VARCHAR(128),
  release_year           SMALLINT,
  original_language_id   SMALLINT,
  spot_watch_price       DECIMAL(4,2),
  length                 SMALLINT,
  stream_uuid            UUID,
  imdb_title_key         VARCHAR(15),
  FOREIGN KEY (content_type_id)
    REFERENCES content_type(content_type_id),
  FOREIGN KEY (original_language_id)
    REFERENCES language(language_id)
);

CREATE TABLE content_actor (
   actor_id INTEGER NOT NULL,
   content_id INTEGER NOT NULL,
   CONSTRAINT pk_content_id PRIMARY KEY (actor_id, content_id),
   FOREIGN KEY (actor_id) REFERENCES actor(actor_id),
   FOREIGN KEY (content_id) REFERENCES content_stream(content_id)
);


CREATE TABLE content_category (
   content_id INTEGER NOT NULL,
   category_id SMALLINT NOT NULL,
   CONSTRAINT pk_category_id PRIMARY KEY (content_id, category_id),
   FOREIGN KEY (content_id) REFERENCES content_stream(content_id),
   FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE content_special_feature (
   content_id INTEGER NOT NULL,
   special_feature_type SMALLINT NOT NULL,
   special_feature_id INTEGER NOT NULL,
   PRIMARY KEY (content_id, special_feature_type, special_feature_id),
   FOREIGN KEY (content_id) REFERENCES content_stream(content_id),
   FOREIGN KEY (special_feature_type) REFERENCES special_feature(special_feature_type),
   FOREIGN KEY (special_feature_id) REFERENCES content_stream(content_id)
);

CREATE INDEX idx_content_stream_fk_content_type_id
  ON content_stream (content_type_id);

CREATE INDEX idx_content_stream_fk_original_language_id
  ON content_stream (original_language_id);


CREATE TABLE franchise (
  franchise_id        SMALLINT   NOT NULL,
  start_content_id    INTEGER,
  franchise_name      VARCHAR(80)  NOT NULL,
  franchise_descr     VARCHAR(255) NOT NULL,
  CONSTRAINT pk_franchise PRIMARY KEY (franchise_id),
  CONSTRAINT fk_franchise_start_content
    FOREIGN KEY (start_content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_franchise_fk_start_content_id
  ON franchise (start_content_id);


CREATE TABLE content_language (
  content_id   INTEGER   NOT NULL,
  language_id  SMALLINT  NOT NULL,
  CONSTRAINT pk_content_language PRIMARY KEY (content_id, language_id),
  CONSTRAINT fk_content_language_content
    FOREIGN KEY (content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_content_language_language
    FOREIGN KEY (language_id)
      REFERENCES language (language_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_content_language_fk_language_id
  ON content_language (language_id);


CREATE TABLE video_quality (
  video_quality_id  SMALLINT      NOT NULL,
  vidquality_label  VARCHAR(5)    NOT NULL,
  vidquality_descr  VARCHAR(40)   NOT NULL,
  CONSTRAINT pk_video_quality PRIMARY KEY (video_quality_id)
);

CREATE TABLE service_type (
  service_type_id    SMALLINT   NOT NULL,
  service_type_name  VARCHAR(128) NOT NULL,
  CONSTRAINT pk_service_type PRIMARY KEY (service_type_id)
);


CREATE TABLE video_quality_price (
  service_type_id    SMALLINT     NOT NULL,
  video_quality_id   SMALLINT     NOT NULL,
  vid_quality_price  DECIMAL(4,2) NOT NULL,
  CONSTRAINT pk_video_quality_price PRIMARY KEY (service_type_id, video_quality_id),
  CONSTRAINT fk_vqp_service_type
    FOREIGN KEY (service_type_id)
      REFERENCES service_type (service_type_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_vqp_video_quality
    FOREIGN KEY (video_quality_id)
      REFERENCES video_quality (video_quality_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_vqp_fk_video_quality_id
  ON video_quality_price (video_quality_id);


CREATE TABLE package (
  package_id       SMALLINT     NOT NULL,
  category_id      SMALLINT     NOT NULL,
  additional_info  VARCHAR(255),
  price            DECIMAL(4,2) NOT NULL,
  CONSTRAINT pk_package PRIMARY KEY (package_id),
  CONSTRAINT fk_package_category
    FOREIGN KEY (category_id)
      REFERENCES category (category_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_package_fk_category_id
  ON package (category_id);


CREATE TABLE subscription (
  subscr_id        SMALLINT     NOT NULL,
  subscr_name      VARCHAR(128) NOT NULL,
  additional_info  VARCHAR(255),
  price            DECIMAL(4,2) NOT NULL,
  CONSTRAINT pk_subscription PRIMARY KEY (subscr_id)
);


CREATE TABLE srv_customer_allocation (
  srv_cust_alloc_id  BIGINT      NOT NULL,
  service_type_id    SMALLINT    NOT NULL,
  srv_reference_id   BIGINT      NOT NULL,
  customer_id        INTEGER     NOT NULL,
  video_quality      SMALLINT    NOT NULL,
  start_date         TIMESTAMP   NOT NULL,
  end_date           TIMESTAMP,
  active             BOOLEAN     NOT NULL DEFAULT TRUE,
  last_update        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_srv_customer_allocation PRIMARY KEY (srv_cust_alloc_id),
  CONSTRAINT fk_sca_service_type
    FOREIGN KEY (service_type_id)
      REFERENCES service_type (service_type_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_sca_video_quality
    FOREIGN KEY (video_quality)
      REFERENCES video_quality (video_quality_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_sca_customer
    FOREIGN KEY (customer_id)
      REFERENCES customer (customer_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT chk_valid_service_type 
    CHECK (service_type_id IN (1, 2, 3))
);

-- Polymorphic Foreign Key Validation Function
CREATE OR REPLACE FUNCTION validate_srv_reference()
RETURNS TRIGGER AS $$
BEGIN
    -- validation based on service_type_id
    CASE NEW.service_type_id
        WHEN 1 THEN -- Subscription
            IF NOT EXISTS (
                SELECT 1 FROM subscription 
                WHERE subscr_id = NEW.srv_reference_id
            ) THEN
                RAISE EXCEPTION 'Invalid subscription ID: %. No subscription found with subscr_id = %', 
                    NEW.srv_reference_id, NEW.srv_reference_id;
            END IF;
            
        WHEN 2 THEN -- Package
            IF NOT EXISTS (
                SELECT 1 FROM package 
                WHERE package_id = NEW.srv_reference_id
            ) THEN
                RAISE EXCEPTION 'Invalid package ID: %. No package found with package_id = %', 
                    NEW.srv_reference_id, NEW.srv_reference_id;
            END IF;
            
        WHEN 3 THEN -- Spot Watching (Content)
            IF NOT EXISTS (
                SELECT 1 FROM content_stream 
                WHERE content_id = NEW.srv_reference_id
            ) THEN
                RAISE EXCEPTION 'Invalid content ID: %. No content found with content_id = %', 
                    NEW.srv_reference_id, NEW.srv_reference_id;
            END IF;
            
        ELSE
            RAISE EXCEPTION 'Unknown service_type_id: %. Valid values are 1 (Subscription), 2 (Package), 3 (Spot Watching)', 
                NEW.service_type_id;
    END CASE;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for srv_customer_allocation
CREATE TRIGGER tr_srv_customer_allocation_validate
    BEFORE INSERT OR UPDATE ON srv_customer_allocation
    FOR EACH ROW
    EXECUTE FUNCTION validate_srv_reference();

CREATE INDEX idx_sca_fk_service_type_id
  ON srv_customer_allocation (service_type_id);

CREATE INDEX idx_sca_fk_reference_id
  ON srv_customer_allocation (srv_reference_id);

CREATE INDEX idx_sca_fk_customer_id
  ON srv_customer_allocation (customer_id);

CREATE INDEX idx_sca_fk_video_quality
  ON srv_customer_allocation (video_quality);


CREATE TABLE billing_head (
  billing_id    BIGINT     NOT NULL,
  customer_id   INTEGER    NOT NULL,
  billing_date  DATE       NOT NULL,
  last_update   TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_billing_head PRIMARY KEY (billing_id),
  CONSTRAINT fk_billing_head_customer
    FOREIGN KEY (customer_id)
      REFERENCES customer (customer_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_billing_head_fk_customer_id
  ON billing_head (customer_id);


CREATE TABLE billing_item (
  billing_id         BIGINT      NOT NULL,
  billing_item_id    BIGINT      NOT NULL,
  srv_cust_alloc_id  BIGINT      NOT NULL,
  service_type_id    SMALLINT    NOT NULL,
  amount             DECIMAL(5,2) NOT NULL,
  last_update        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_billing_item PRIMARY KEY (billing_id, billing_item_id),
  CONSTRAINT fk_bitem_billing_head
    FOREIGN KEY (billing_id)
      REFERENCES billing_head (billing_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_bitem_sca
    FOREIGN KEY (srv_cust_alloc_id)
      REFERENCES srv_customer_allocation (srv_cust_alloc_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_bitem_service_type
    FOREIGN KEY (service_type_id)
      REFERENCES service_type (service_type_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_billing_item_fk_sca_id
  ON billing_item (srv_cust_alloc_id);

CREATE INDEX idx_billing_item_fk_service_type_id
  ON billing_item (service_type_id);




ALTER TABLE payment
ADD column billing_id bigint,
ADD CONSTRAINT fk_billing_id
FOREIGN KEY (billing_id) REFERENCES billing_head(billing_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE payment 
DROP CONSTRAINT pk_payment;

ALTER TABLE payment
ALTER COLUMN payment_id TYPE BIGINT;

ALTER TABLE payment
ADD CONSTRAINT pk_payment PRIMARY KEY (payment_id);




CREATE TABLE package_content (
  package_id  SMALLINT  NOT NULL,
  content_id  INTEGER   NOT NULL,
  CONSTRAINT pk_package_content PRIMARY KEY (package_id, content_id),
  CONSTRAINT fk_pkgcontent_package
    FOREIGN KEY (package_id)
      REFERENCES package (package_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_pkgcontent_content
    FOREIGN KEY (content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_package_content_fk_content_id
  ON package_content (content_id);


CREATE TABLE customer_watchlist (
  watchlist_id   INTEGER     NOT NULL,
  customer_id    INTEGER     NOT NULL,
  creation_date  TIMESTAMP   NOT NULL,
  name           VARCHAR(25) NOT NULL,
  description    VARCHAR(255),
  last_update    TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_customer_watchlist PRIMARY KEY (watchlist_id),
  CONSTRAINT fk_customer_watchlist_customer
    FOREIGN KEY (customer_id)
      REFERENCES customer (customer_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_customer_watchlist_fk_customer_id
  ON customer_watchlist (customer_id);


CREATE TABLE cust_watchlist_item (
  watchlist_id  INTEGER    NOT NULL,
  content_id    INTEGER    NOT NULL,
  seq_num       SMALLINT   NOT NULL,
  last_update   TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_cust_watchlist_item PRIMARY KEY (watchlist_id, content_id),
  CONSTRAINT fk_cust_watchlist_item_watchlist
    FOREIGN KEY (watchlist_id)
      REFERENCES customer_watchlist (watchlist_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_cust_watchlist_item_content
    FOREIGN KEY (content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_cust_watchlist_item_fk_content_id
  ON cust_watchlist_item (content_id);


CREATE TABLE cust_watch_act (
  cust_watch_act_id  BIGINT     NOT NULL,
  customer_id        INTEGER    NOT NULL,
  content_id         INTEGER    NOT NULL,
  start_date         TIMESTAMP  NOT NULL,
  time_index_seconds SMALLINT,
  completion_date    TIMESTAMP,
  last_update        TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_cust_watch_act PRIMARY KEY (cust_watch_act_id),
  CONSTRAINT fk_cust_watch_act_customer
    FOREIGN KEY (customer_id)
      REFERENCES customer (customer_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_cust_watch_act_content
    FOREIGN KEY (content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_cust_watch_act_fk_customer_id
  ON cust_watch_act (customer_id);

CREATE INDEX idx_cust_watch_act_fk_content_id
  ON cust_watch_act (content_id);


CREATE TABLE content_country_restricted (
  country_id INTEGER NOT NULL,
  content_id INTEGER  NOT NULL,
  CONSTRAINT pk_content_country_restricted PRIMARY KEY (country_id, content_id),
  CONSTRAINT fk_ccr_country
    FOREIGN KEY (country_id)
      REFERENCES country (country_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_ccr_content
    FOREIGN KEY (content_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE INDEX idx_ccr_fk_content_id
  ON content_country_restricted (content_id);


CREATE TABLE binge_flow (
  current_id     INTEGER   NOT NULL,
  next_content   INTEGER   NOT NULL,
  franchise_id   SMALLINT  NOT NULL,
  CONSTRAINT pk_binge_flow PRIMARY KEY (current_id, next_content),
  CONSTRAINT fk_binge_flow_current
    FOREIGN KEY (current_id)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_binge_flow_next
    FOREIGN KEY (next_content)
      REFERENCES content_stream (content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_binge_flow_franchise
    FOREIGN KEY (franchise_id)
      REFERENCES franchise (franchise_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);



CREATE INDEX idx_binge_flow_fk_next_content
  ON binge_flow (next_content);

CREATE INDEX idx_binge_flow_fk_franchise_id
  ON binge_flow (franchise_id);



CREATE TABLE series (
  series_id     INTEGER     PRIMARY KEY,
  content_id    INTEGER     NOT NULL,
  franchise_id  SMALLINT    NOT NULL,
  CONSTRAINT fk_series_content   
    FOREIGN KEY (content_id)   
      REFERENCES content_stream(content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_series_franchise
    FOREIGN KEY (franchise_id)
      REFERENCES franchise(franchise_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE season (
  season_id      INTEGER   PRIMARY KEY,
  series_id      INTEGER   NOT NULL,
  content_id     INTEGER   NOT NULL,
  season_number  SMALLINT  NOT NULL,
  CONSTRAINT fk_season_series
    FOREIGN KEY (series_id)
      REFERENCES series(series_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_season_content
    FOREIGN KEY (content_id)
      REFERENCES content_stream(content_id)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE episode (
  episode_id     INTEGER   PRIMARY KEY,
  season_id      INTEGER   NOT NULL,
  content_id     INTEGER   NOT NULL,
  episode_number SMALLINT  NOT NULL,
  CONSTRAINT fk_episode_season
    FOREIGN KEY (season_id)
      REFERENCES season(season_id)
      ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_episode_content
    FOREIGN KEY (content_id)
    REFERENCES content_stream(content_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);