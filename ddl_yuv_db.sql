create table yuv_main.alarm_setting_types
(
    id   smallint auto_increment
        primary key,
    name varchar(32) not null
);

create table yuv_main.alarm_types
(
    id   smallint    not null
        primary key,
    name varchar(50) not null,
    icon char        null
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.asset_daily_metrics
(
    asset_id       bigint                              not null,
    dealer_id      bigint                              not null,
    customer_id    bigint                              null,
    device_imei    varchar(20)                         not null,
    had_moved      tinyint(1)                          not null,
    time_online    bigint                              null,
    time_offline   bigint                              null,
    km_traveled    decimal(10, 2)                      null,
    max_speed      int                                 null,
    avg_speed      decimal(10, 2)                      null,
    min_odometer   int                                 null,
    max_odometer   int                                 null,
    avg_odometer   decimal(10, 2)                      null,
    min_hourmeter  int                                 null,
    max_hourmeter  int                                 null,
    avg_hourmeter  decimal(10, 2)                      null,
    used_odometer  int                                 null,
    used_hourmeter int                                 null,
    reference_date date                                not null,
    created_at     timestamp default CURRENT_TIMESTAMP null,
    primary key (asset_id, reference_date)
);

create index asset_daily_metrics_asset_dealer_customer_imei_ref_date_index
    on yuv_main.asset_daily_metrics (asset_id, dealer_id, customer_id, device_imei, reference_date);

create index asset_daily_metrics_asset_dealer_customer_ref_date_index
    on yuv_main.asset_daily_metrics (asset_id, dealer_id, customer_id, reference_date);

create index asset_daily_metrics_asset_dealer_imei_ref_date_index
    on yuv_main.asset_daily_metrics (asset_id, dealer_id, device_imei, reference_date);

create index asset_daily_metrics_asset_dealer_ref_date_index
    on yuv_main.asset_daily_metrics (asset_id, dealer_id, reference_date);

create table yuv_main.asset_movements
(
    id           bigint auto_increment
        primary key,
    asset_id     bigint                              not null,
    dealer_id    bigint                              not null,
    customer_id  bigint                              null,
    device_imei  varchar(20)                         not null,
    start_hour   datetime                            not null,
    start_lat    decimal(10, 6)                      not null,
    start_lng    decimal(10, 6)                      not null,
    start_locale varchar(255)                        null,
    end_hour     datetime                            not null,
    end_lat      decimal(10, 6)                      not null,
    end_lng      decimal(10, 6)                      not null,
    end_locale   varchar(255)                        null,
    duration     bigint                              not null comment 'Dura��o em ms',
    event        varchar(50)                         not null,
    km_traveled  decimal(10, 2)                      not null,
    max_speed    int                                 not null,
    qty_alarms   int                                 not null,
    created_at   timestamp default CURRENT_TIMESTAMP not null
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index asset_movements_asset_dealer_mei_start_end_index
    on yuv_main.asset_movements (asset_id, dealer_id, device_imei, start_hour, end_hour);

create index asset_movements_asset_id_dealer_index
    on yuv_main.asset_movements (asset_id, dealer_id, device_imei);

create index asset_movements_device_imei_index
    on yuv_main.asset_movements (device_imei);

create table yuv_main.attribute_types
(
    id         bigint auto_increment
        primary key,
    name       varchar(100)                       not null,
    created_at datetime default CURRENT_TIMESTAMP null,
    updated_at datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint uq_name
        unique (name)
);

create table yuv_main.authentication_logs
(
    id                   bigint auto_increment
        primary key,
    authenticatable_type varchar(100) not null,
    authenticatable_id   bigint       not null,
    ip_address           varchar(20)  null,
    user_agent           text         null,
    login_at             datetime     not null,
    login_successful     tinyint(1)   not null
);

create index authentication_logs_authenticatable_type_index
    on yuv_main.authentication_logs (authenticatable_id asc, login_at desc);

create table yuv_main.automation_field_definitions
(
    id              bigint auto_increment
        primary key,
    table_reference varchar(255)                                                         not null,
    field_name      varchar(100)                                                         not null,
    event_trigger   varchar(255)                                                         null,
    field_type      enum ('number', 'string', 'boolean', 'datetime', 'duration', 'enum') not null,
    translation_key varchar(255)                                                         not null,
    description     text                                                                 null,
    example_value   varchar(255)                                                         null,
    constraint table_reference
        unique (table_reference, field_name, event_trigger)
);

create table yuv_main.automation_rule_allowed_tables
(
    id              bigint auto_increment
        primary key,
    table_reference varchar(255) not null,
    trigger_events  json         not null,
    trigger_actions json         not null,
    constraint table_reference
        unique (table_reference)
)
    collate = utf8mb4_unicode_ci;

create table yuv_main.aws_arrived_files
(
    file_name  varchar(510)                       not null,
    file_size  bigint                             null,
    created_at datetime default CURRENT_TIMESTAMP not null
);

create index aws_arrived_files_file_name_index
    on yuv_main.aws_arrived_files (file_name asc, created_at desc);

create table yuv_main.badges
(
    id          bigint auto_increment
        primary key,
    name        varchar(100)                        not null,
    description text                                not null,
    created_at  timestamp default CURRENT_TIMESTAMP null,
    updated_at  timestamp default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP
);

create table yuv_main.billing_customer_custom_prices
(
    id                     bigint unsigned auto_increment
        primary key,
    customer_id            bigint                             not null,
    product_id             int                                not null,
    fixed_unit_price_cents int                                not null,
    created_at             datetime default CURRENT_TIMESTAMP not null,
    updated_at             datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint uq_bccp_customer_product
        unique (customer_id, product_id)
)
    collate = utf8mb4_0900_ai_ci;

create table yuv_main.billing_customers
(
    id                bigint unsigned auto_increment
        primary key,
    customer_id       bigint                             not null,
    asaas_customer_id varchar(64)                        not null,
    created_at        datetime default CURRENT_TIMESTAMP not null,
    updated_at        datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint uq_billing_customers_customer
        unique (customer_id)
)
    collate = utf8mb4_0900_ai_ci;

create table yuv_main.billing_notifications
(
    id            int auto_increment
        primary key,
    dealer_id     int                                      not null,
    customer_id   int                                      null,
    license_plate varchar(50)                              not null,
    amount        decimal(10, 2) default 15.00             null,
    month_year    varchar(7)                               not null,
    created_at    datetime       default CURRENT_TIMESTAMP null,
    constraint unique_billing
        unique (dealer_id, customer_id, license_plate, month_year)
);

create table yuv_main.billing_settings_group
(
    id                     int auto_increment
        primary key,
    name                   varchar(200)                        not null,
    price_per_device_cents int                                 not null,
    discount_cents         int                                 not null,
    min_devices            int       default 0                 not null,
    created_at             timestamp default CURRENT_TIMESTAMP not null,
    updated_at             timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP
);

create table yuv_main.cnh_categories
(
    id       smallint   not null
        primary key,
    category varchar(5) not null
);

create table yuv_main.dealer_webhook_retry_queue
(
    id              bigint auto_increment
        primary key,
    dealer_id       bigint                             not null,
    path            varchar(255)                       not null,
    body            text                               not null,
    created_at      datetime default CURRENT_TIMESTAMP not null,
    last_attempt_at datetime default CURRENT_TIMESTAMP not null
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index dealer_webhook_retry_queue_created_at_IDX
    on yuv_main.dealer_webhook_retry_queue (created_at desc);

create index dealer_webhook_retry_queue_dealer_id_index
    on yuv_main.dealer_webhook_retry_queue (dealer_id);

create index dealer_webhook_retry_queue_last_attempt_at_index
    on yuv_main.dealer_webhook_retry_queue (last_attempt_at);

create table yuv_main.dealer_webhooks
(
    dealer_id int          not null,
    base_url  varchar(255) not null,
    token     text         null
);

create table yuv_main.device_lines
(
    id   smallint    not null
        primary key,
    name varchar(50) not null
);

create table yuv_main.device_manufacturers
(
    id   smallint    not null
        primary key,
    name varchar(50) not null
);

create table yuv_main.device_models
(
    id                     smallint             not null
        primary key,
    device_line_id         smallint             not null,
    device_manufacturer_id smallint             not null,
    device_protocol_id     smallint             null,
    name                   varchar(100)         not null,
    is_integrated          tinyint(1) default 0 null,
    constraint device_lines_device_manufacturers_FK
        foreign key (device_manufacturer_id) references yuv_main.device_manufacturers (id),
    constraint device_models_device_lines_FK
        foreign key (device_line_id) references yuv_main.device_lines (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.command_queue
(
    id              bigint auto_increment
        primary key,
    device_model_id smallint                                 not null,
    device_imei     varchar(50)                              not null,
    command         text                                     not null,
    status          enum ('PENDING', 'COMPLETED', 'EXPIRED') not null,
    response        text                                     null,
    created_at      datetime default CURRENT_TIMESTAMP       not null,
    sent_at         datetime                                 null,
    response_at     datetime                                 null,
    expires_at      datetime                                 not null,
    constraint command_queue_device_models_FK
        foreign key (device_model_id) references yuv_main.device_models (id)
            on update cascade on delete cascade
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index command_queue_device_imei_IDX
    on yuv_main.command_queue (device_imei asc, created_at desc);

create index command_queue_status_IDX
    on yuv_main.command_queue (status, created_at);

create table yuv_main.device_privacy_rules
(
    id           int auto_increment
        primary key,
    customer_id  int                                                                                null,
    feature      enum ('STREAMING', 'PLAYBACK', 'DOWNLOAD')                                         null,
    start_time   time                                                                               null,
    end_time     time                                                                               null,
    days_of_week set ('monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday') null,
    created_at   timestamp default CURRENT_TIMESTAMP                                                null,
    updated_at   timestamp default CURRENT_TIMESTAMP                                                null,
    constraint customer_id
        unique (customer_id, feature)
);

create table yuv_main.device_protocols
(
    id   smallint auto_increment
        primary key,
    name varchar(30) not null
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.device_channels
(
    id                 smallint auto_increment
        primary key,
    device_model_id    smallint null,
    device_protocol_id smallint null,
    channels           json     null,
    constraint device_channels_fk_1
        foreign key (device_model_id) references yuv_main.device_models (id),
    constraint device_channels_fk_2
        foreign key (device_protocol_id) references yuv_main.device_protocols (id)
);

create table yuv_main.file_list_request
(
    id          bigint auto_increment
        primary key,
    device_imei varchar(50)                              not null,
    status      enum ('PENDING', 'COMPLETED', 'EXPIRED') not null,
    file_date   date                                     null,
    created_at  timestamp default CURRENT_TIMESTAMP      not null
);

create index file_list_request_device_imei_index
    on yuv_main.file_list_request (device_imei);

create index file_list_request_status_index
    on yuv_main.file_list_request (created_at desc, status asc);

create table yuv_main.file_list_response_custom
(
    file_list_request_id bigint      not null,
    begin_time           datetime    not null,
    end_time             datetime    not null,
    channel              int         not null,
    file_size            int         null,
    storage_type         int         not null,
    resource             varchar(30) null,
    constraint file_list_response_custom_ibfk_1
        foreign key (file_list_request_id) references yuv_main.file_list_request (id)
);

create index file_list_request_id
    on yuv_main.file_list_response_custom (file_list_request_id);

create table yuv_main.file_list_response_jc400
(
    file_list_request_id bigint     not null,
    files                mediumtext not null,
    constraint file_list_response_jc400_ibfk_1
        foreign key (file_list_request_id) references yuv_main.file_list_request (id)
);

create index file_list_request_id
    on yuv_main.file_list_response_jc400 (file_list_request_id);

create table yuv_main.file_list_response_jc450
(
    file_list_request_id bigint   not null,
    code_type            int      null,
    file_size            int      null,
    channel              int      not null,
    storage_type         int      not null,
    begin_time           datetime not null,
    end_time             datetime not null,
    alarm_flag           int      null,
    resource_type        int      null,
    constraint file_list_response_jc450_ibfk_1
        foreign key (file_list_request_id) references yuv_main.file_list_request (id)
);

create index file_list_request_id
    on yuv_main.file_list_response_jc450 (file_list_request_id);

create table yuv_main.firmwares
(
    id              smallint     not null
        primary key,
    device_model_id smallint     not null,
    name            varchar(100) not null,
    reference       varchar(255) null,
    constraint firmwares_device_model_id_fk
        foreign key (device_model_id) references yuv_main.device_models (id)
);

create table yuv_main.gps
(
    id                       bigint auto_increment,
    asset_id                 bigint                             null,
    device_model_id          smallint                           not null,
    dealer_id                bigint                             not null,
    customer_id              bigint                             null,
    device_imei              varchar(50)                        not null,
    latitude                 decimal(10, 6)                     not null,
    longitude                decimal(10, 6)                     not null,
    address                  text                               null,
    gps_time                 datetime                           not null,
    gate_time                datetime default CURRENT_TIMESTAMP not null,
    ignition                 tinyint(1)                         null,
    odometer                 int                                null,
    speed                    int                                null,
    inputs                   varchar(20)                        null,
    outputs                  varchar(20)                        null,
    internal_battery_voltage decimal(10, 2)                     null,
    external_battery_voltage decimal(10, 2)                     null,
    gps_number               int                                null,
    event_type               int                                null,
    additional_data          json                               null,
    primary key (id, gps_time),
    constraint gps_unique_new
        unique (device_imei, device_model_id, gps_time, event_type)
)
    partition by range (to_days(`gps_time`));

create index gps_asset_id_gps_time_customer_id_event_type_index
    on yuv_main.gps (asset_id asc, gps_time desc, customer_id asc, event_type asc);

create index gps_asset_id_gps_time_dealer_id_customer_id_event_type_index
    on yuv_main.gps (asset_id asc, gps_time desc, dealer_id asc, customer_id asc, event_type asc);

create index gps_asset_id_gps_time_dealer_id_event_type_index
    on yuv_main.gps (asset_id asc, gps_time desc, dealer_id asc, event_type asc);

create index gps_device_imei_gps_time_customer_id_event_type_index
    on yuv_main.gps (device_imei asc, gps_time desc, customer_id asc, event_type asc);

create index gps_device_imei_gps_time_dealer_id_customer_id_event_type_index
    on yuv_main.gps (device_imei asc, gps_time desc, dealer_id asc, customer_id asc, event_type asc);

create index gps_device_imei_gps_time_dealer_id_event_type_index
    on yuv_main.gps (device_imei asc, gps_time desc, dealer_id asc, event_type asc);

create index gps_gate_time_index
    on yuv_main.gps (gate_time desc);

create index gps_gps_time_index
    on yuv_main.gps (gps_time desc);

create index idx_gps_new_asset
    on yuv_main.gps (asset_id);

create index idx_gps_new_device_model
    on yuv_main.gps (device_model_id);

create table yuv_main.languages
(
    id    smallint     not null
        primary key,
    name  varchar(100) not null,
    value varchar(10)  not null
);

create table yuv_main.last_read_record
(
    id             smallint auto_increment
        primary key,
    name           varchar(255) not null,
    value_int      bigint       null,
    value_datetime datetime     null,
    value_string   varchar(255) null
);

create table yuv_main.maintenances
(
    id          bigint unsigned auto_increment
        primary key,
    dealer_id   bigint unsigned not null,
    name        varchar(255)    not null,
    description text            null,
    hourmeter   int             null,
    odometer    int             null,
    created_at  timestamp       null,
    updated_at  timestamp       null
);

create table yuv_main.onboarding_tours
(
    id          bigint unsigned auto_increment
        primary key,
    name        varchar(255) not null,
    description varchar(255) not null,
    created_at  timestamp    null,
    updated_at  timestamp    null,
    constraint name
        unique (name)
)
    collate = utf8mb4_unicode_ci;

create table yuv_main.onboarding_tour_user_assignments
(
    id                 bigint unsigned auto_increment
        primary key,
    onboarding_tour_id bigint unsigned not null,
    user_type_id       smallint        not null,
    created_at         timestamp       null,
    updated_at         timestamp       null,
    constraint tour_user_assignment_unique
        unique (onboarding_tour_id, user_type_id),
    constraint fk_assignments_tour
        foreign key (onboarding_tour_id) references yuv_main.onboarding_tours (id)
            on delete cascade
)
    collate = utf8mb4_unicode_ci;

create index idx_onboarding_tour_id
    on yuv_main.onboarding_tour_user_assignments (onboarding_tour_id);

create index idx_user_type_id
    on yuv_main.onboarding_tour_user_assignments (user_type_id);

create index idx_name
    on yuv_main.onboarding_tours (name);

create table yuv_main.operators
(
    id          int auto_increment
        primary key,
    symbol      varchar(10)  not null,
    description varchar(100) not null,
    constraint symbol
        unique (symbol)
);

create table yuv_main.password_resets
(
    email      varchar(50)                        not null,
    token      varchar(255)                       not null,
    created_at datetime default CURRENT_TIMESTAMP not null,
    expires_at datetime                           not null,
    constraint password_resets_unique
        unique (email)
);

create table yuv_main.permission_modules
(
    id   smallint auto_increment
        primary key,
    name varchar(50) not null
);

create table yuv_main.permission_user_types
(
    permission_id int      not null,
    user_type_id  smallint not null
);

create index permission_user_types_permission_id_IDX
    on yuv_main.permission_user_types (permission_id);

create table yuv_main.permissions
(
    id                   int auto_increment
        primary key,
    permission_module_id smallint     not null,
    name                 varchar(100) not null,
    description          varchar(100) not null,
    constraint permissions_permission_modules_FK
        foreign key (permission_module_id) references yuv_main.permission_modules (id)
);

create table yuv_main.report_export_assets
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint       not null,
    dealer_id        bigint       null,
    search           varchar(200) null
);

create table yuv_main.report_export_customer
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint       not null,
    dealer_id        bigint       null,
    search           varchar(200) null
);

create table yuv_main.report_export_device
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint       not null,
    dealer_id        bigint       null,
    customer_id      bigint       null,
    search           varchar(200) null,
    device_model_id  smallint     null,
    status           int          null,
    constraint report_export_device_device_model_id_fkey
        foreign key (device_model_id) references yuv_main.device_models (id)
);

create table yuv_main.report_export_sim_cards
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint       not null,
    dealer_id        bigint       null,
    search           varchar(200) null
);

create table yuv_main.sales_representatives
(
    id   int auto_increment
        primary key,
    name varchar(100) not null
);

create table yuv_main.dealers
(
    id                           bigint auto_increment
        primary key,
    customer_permission_group_id bigint                               not null,
    sales_representative_id      int                                  null,
    billing_settings_group_id    int        default 1                 not null,
    name                         varchar(200)                         not null,
    legal_name                   varchar(200)                         null,
    cnpj                         varchar(20)                          null,
    email                        varchar(100)                         null,
    email_2                      varchar(255)                         null,
    email_3                      varchar(255)                         null,
    phone_1                      varchar(20)                          null,
    phone_2                      varchar(20)                          null,
    phone_3                      varchar(20)                          null,
    domain                       varchar(200)                         null,
    logo                         varchar(200)                         null,
    logo_login                   varchar(200)                         null,
    background_login             varchar(200)                         null,
    is_dvr_audio_enabled         tinyint(1) default 1                 not null,
    is_googlemaps_enabled        tinyint(1) default 0                 not null,
    is_enabled                   tinyint(1) default 1                 not null,
    created_at                   timestamp  default CURRENT_TIMESTAMP not null,
    updated_at                   timestamp  default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    deleted_at                   timestamp                            null,
    commercial_indication        varchar(200)                         null,
    accepted_terms               tinyint(1) default 0                 null,
    accepted_terms_at            timestamp                            null,
    yuvxp_info                   varchar(255)                         null,
    qrcode_token                 varchar(255)                         null,
    accepted_yuvxp_terms         tinyint(1)                           null,
    accepted_yuvxp_terms_at      datetime                             null,
    has_changes                  tinyint(1) default 0                 not null,
    stream_audio                 tinyint(1) default 1                 not null,
    constraint dealers_billing_settings_group_FK
        foreign key (billing_settings_group_id) references yuv_main.billing_settings_group (id),
    constraint dealers_sales_representatives_FK
        foreign key (sales_representative_id) references yuv_main.sales_representatives (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.alarm_settings
(
    id         bigint auto_increment
        primary key,
    dealer_id  bigint                              null,
    name       varchar(50)                         not null,
    created_at timestamp default CURRENT_TIMESTAMP not null,
    updated_at timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    deleted_at timestamp                           null,
    constraint alarm_settings_ibfk_1
        foreign key (dealer_id) references yuv_main.dealers (id)
);

create table yuv_main.alarm_setting_rules
(
    alarm_setting_id      bigint   not null,
    alarm_setting_type_id smallint not null,
    alarm_type_id         smallint not null,
    primary key (alarm_setting_id, alarm_setting_type_id, alarm_type_id),
    constraint alarm_setting_rules_ibfk_1
        foreign key (alarm_setting_id) references yuv_main.alarm_settings (id),
    constraint alarm_setting_rules_ibfk_2
        foreign key (alarm_setting_type_id) references yuv_main.alarm_setting_types (id),
    constraint alarm_setting_rules_ibfk_3
        foreign key (alarm_type_id) references yuv_main.alarm_types (id)
);

create index alarm_setting_type_id
    on yuv_main.alarm_setting_rules (alarm_setting_type_id);

create index alarm_type_id
    on yuv_main.alarm_setting_rules (alarm_type_id);

create index dealer_id
    on yuv_main.alarm_settings (dealer_id);

create table yuv_main.billings
(
    id                     bigint auto_increment
        primary key,
    dealer_id              bigint                             not null,
    `year_month`           varchar(7)                         not null,
    start_date             date                               not null,
    end_date               date                               not null,
    total_devices          int                                not null,
    price_per_device_cents int                                not null,
    discount_cents         int                                not null,
    min_devices            int                                not null,
    total_amount           decimal(10, 2)                     null,
    created_at             datetime default CURRENT_TIMESTAMP not null,
    constraint billings_dealer_id_fkey
        foreign key (dealer_id) references yuv_main.dealers (id)
);

create table yuv_main.billing_devices
(
    id               bigint auto_increment
        primary key,
    billing_id       bigint       not null,
    customer_id      bigint       not null,
    device_id        bigint       not null,
    asset_identifier varchar(100) null,
    asset_prefix     varchar(100) null,
    device_imei      varchar(50)  null,
    device_model     varchar(50)  null,
    customer_name    varchar(100) null,
    start_date       date         not null,
    end_date         date         not null,
    days             int          not null,
    constraint billing_devices_billing_id_fkey
        foreign key (billing_id) references yuv_main.billings (id)
);

create index billings_dealer_id_index
    on yuv_main.billings (`year_month`, dealer_id);

create table yuv_main.checklists
(
    id          bigint auto_increment
        primary key,
    name        varchar(100)                        not null,
    dealer_id   bigint                              not null,
    customer_id bigint                              null,
    created_at  timestamp default CURRENT_TIMESTAMP null,
    updated_at  timestamp default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint checklists_ibfk_1
        foreign key (dealer_id) references yuv_main.dealers (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.checklist_items
(
    id                bigint auto_increment
        primary key,
    checklist_id      bigint                               not null,
    name              varchar(50)                          not null,
    description       varchar(100)                         not null,
    attribute_type_id bigint                               not null,
    is_required       tinyint(1) default 0                 not null,
    is_file_required  tinyint(1) default 0                 not null,
    created_at        timestamp  default CURRENT_TIMESTAMP null,
    updated_at        timestamp  default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    options           json                                 null,
    has_file          tinyint(1) default 0                 not null,
    has_observation   tinyint(1) default 1                 not null,
    constraint checklist_items_ibfk_1
        foreign key (checklist_id) references yuv_main.checklists (id),
    constraint checklist_items_ibfk_2
        foreign key (attribute_type_id) references yuv_main.attribute_types (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index attribute_type_id
    on yuv_main.checklist_items (attribute_type_id);

create index checklist_id
    on yuv_main.checklist_items (checklist_id);

create index idx_checklists_dealer_id
    on yuv_main.checklists (dealer_id);

create table yuv_main.dealer_histories
(
    id         bigint auto_increment
        primary key,
    dealer_id  bigint               not null,
    user_id    bigint               null,
    is_enabled tinyint(1) default 1 not null,
    changed_at datetime             null,
    constraint dealer_histories_dealers_FK
        foreign key (dealer_id) references yuv_main.dealers (id)
);

create index dealer_histories_dealer_id_index
    on yuv_main.dealer_histories (dealer_id desc);

create table yuv_main.dealer_themes
(
    id                         bigint auto_increment
        primary key,
    dealer_id                  bigint                              not null,
    primary_color              varchar(7)                          null,
    primary_color_inverted     varchar(7)                          null,
    sidebar_text_color         varchar(7)                          null,
    sidebar_background_color   varchar(7)                          null,
    background_primary_color   varchar(7)                          null,
    background_secondary_color varchar(7)                          null,
    created_at                 timestamp default CURRENT_TIMESTAMP not null,
    updated_at                 timestamp default CURRENT_TIMESTAMP not null,
    constraint dealer_themes_dealers_FK
        foreign key (dealer_id) references yuv_main.dealers (id)
            on update cascade on delete cascade
);

create table yuv_main.occurrence_settings
(
    id         bigint auto_increment
        primary key,
    dealer_id  bigint                               null,
    name       varchar(50)                          not null,
    is_default tinyint(1) default 0                 not null,
    created_at timestamp  default CURRENT_TIMESTAMP not null,
    updated_at timestamp  default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    deleted_at timestamp                            null,
    constraint occurrence_settings_dealers_FK
        foreign key (dealer_id) references yuv_main.dealers (id)
);

create table yuv_main.customers
(
    id                    bigint auto_increment
        primary key,
    dealer_id             bigint                               not null,
    occurrence_setting_id bigint                               null,
    alarm_setting_id      bigint                               null,
    name                  varchar(200)                         not null,
    zip_code              varchar(45)                          null,
    address               varchar(255)                         null,
    complement            varchar(255)                         null,
    neighborhood          varchar(255)                         null,
    city                  varchar(255)                         null,
    state                 varchar(100)                         null,
    phone                 varchar(45)                          null,
    observation           text                                 null,
    streaming_limit       smallint unsigned                    null,
    is_enabled            tinyint(1) default 1                 not null,
    created_at            timestamp  default CURRENT_TIMESTAMP not null,
    updated_at            timestamp  default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    deleted_at            timestamp                            null,
    constraint customers_dealers_FK
        foreign key (dealer_id) references yuv_main.dealers (id),
    constraint customers_occurrence_settings_FK
        foreign key (occurrence_setting_id) references yuv_main.occurrence_settings (id)
            on update cascade on delete set null,
    constraint fk_alarm_setting_customer
        foreign key (alarm_setting_id) references yuv_main.alarm_settings (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.asset_groups
(
    id          bigint auto_increment
        primary key,
    dealer_id   bigint       null,
    customer_id bigint       null,
    name        varchar(100) not null,
    constraint asset_groups_customer_id_fk
        foreign key (customer_id) references yuv_main.customers (id)
            on delete cascade,
    constraint asset_groups_dealer_id_fk
        foreign key (dealer_id) references yuv_main.dealers (id)
            on delete cascade
);

create table yuv_main.automation_rules
(
    id              bigint auto_increment
        primary key,
    name            varchar(255)                         not null,
    description     text                                 null,
    dealer_id       bigint                               not null,
    customer_id     bigint                               null,
    table_reference varchar(255)                         not null,
    table_id        bigint                               null,
    trigger_event   varchar(255)                         null,
    is_enabled      tinyint(1) default 1                 null,
    created_at      datetime   default CURRENT_TIMESTAMP null,
    updated_at      datetime   default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint fk_automation_rules_customer
        foreign key (customer_id) references yuv_main.customers (id)
            on delete cascade,
    constraint fk_automation_rules_dealer
        foreign key (dealer_id) references yuv_main.dealers (id)
            on delete cascade
);

create table yuv_main.automation_actions
(
    id             bigint auto_increment
        primary key,
    rule_id        bigint       not null,
    trigger_action varchar(255) not null,
    parameters     json         null,
    constraint fk_actions_rule
        foreign key (rule_id) references yuv_main.automation_rules (id)
            on delete cascade
);

create table yuv_main.automation_condition_groups
(
    id               bigint auto_increment
        primary key,
    rule_id          bigint                           not null,
    parent_group_id  bigint                           null,
    logical_operator enum ('AND', 'OR') default 'AND' null,
    constraint fk_condition_groups_parent
        foreign key (parent_group_id) references yuv_main.automation_condition_groups (id)
            on delete cascade,
    constraint fk_condition_groups_rule
        foreign key (rule_id) references yuv_main.automation_rules (id)
            on delete cascade
);

create table yuv_main.automation_conditions
(
    id          bigint auto_increment
        primary key,
    group_id    bigint       not null,
    field_id    bigint       not null,
    operator_id int          not null,
    value       varchar(255) not null,
    constraint fk_conditions_field
        foreign key (field_id) references yuv_main.automation_field_definitions (id)
            on delete cascade,
    constraint fk_conditions_group
        foreign key (group_id) references yuv_main.automation_condition_groups (id)
            on delete cascade,
    constraint fk_conditions_operator
        foreign key (operator_id) references yuv_main.operators (id)
);

create table yuv_main.branches
(
    id          bigint auto_increment
        primary key,
    customer_id bigint                             not null,
    name        varchar(100)                       not null,
    created_at  datetime default CURRENT_TIMESTAMP not null,
    updated_at  datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint branches_customers_id_FK
        foreign key (customer_id) references yuv_main.customers (id)
            on update cascade on delete cascade
);

create table yuv_main.asset_group_branches
(
    asset_group_id bigint not null,
    branch_id      bigint not null,
    primary key (asset_group_id, branch_id),
    constraint asset_group_branches_branch_id_fk
        foreign key (branch_id) references yuv_main.branches (id)
            on delete cascade,
    constraint asset_group_branches_id_asset_group_id_fk
        foreign key (asset_group_id) references yuv_main.asset_groups (id)
            on delete cascade
);

create index branches_name_IDX
    on yuv_main.branches (name);

create table yuv_main.drivers
(
    id                      bigint auto_increment
        primary key,
    dealer_id               bigint                               not null,
    customer_id             bigint                               null,
    name                    varchar(200)                         not null,
    picture                 text                                 null,
    identifier              varchar(200)                         null,
    birth_date              date                                 null,
    cnh                     varchar(20)                          null,
    cnh_expires_at          date                                 null,
    medical_exam_expires_at date                                 null,
    enable_app_access       tinyint(1) default 0                 null,
    cpf                     char(14)                             null,
    password                varchar(255)                         null,
    created_at              datetime   default CURRENT_TIMESTAMP not null,
    updated_at              datetime   default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    deleted_at              timestamp                            null,
    constraint cpf
        unique (cpf),
    constraint drivers_customers_FK
        foreign key (customer_id) references yuv_main.customers (id)
            on update cascade on delete cascade,
    constraint drivers_dealers_FK
        foreign key (dealer_id) references yuv_main.dealers (id)
            on update cascade on delete cascade
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.badge_drivers
(
    id         bigint auto_increment
        primary key,
    driver_id  bigint                              not null,
    badge_id   bigint                              not null,
    earned_at  timestamp                           not null,
    created_at timestamp default CURRENT_TIMESTAMP null,
    updated_at timestamp default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint badge_drivers_ibfk_1
        foreign key (driver_id) references yuv_main.drivers (id),
    constraint badge_drivers_ibfk_2
        foreign key (badge_id) references yuv_main.badges (id)
);

create index idx_badge_drivers_badge_id
    on yuv_main.badge_drivers (badge_id);

create index idx_badge_drivers_driver_id
    on yuv_main.badge_drivers (driver_id);

create table yuv_main.checklist_drivers
(
    checklist_id bigint not null,
    driver_id    bigint not null,
    constraint checklist_drivers_checklist_id_fkey
        foreign key (checklist_id) references yuv_main.checklists (id)
            on delete cascade,
    constraint checklist_drivers_driver_id_fkey
        foreign key (driver_id) references yuv_main.drivers (id)
            on delete cascade
);

create table yuv_main.driver_branches
(
    driver_id bigint not null,
    branch_id bigint not null,
    primary key (driver_id, branch_id),
    constraint uq_driver_branch
        unique (driver_id, branch_id),
    constraint driver_branches_ibfk_1
        foreign key (driver_id) references yuv_main.drivers (id),
    constraint driver_branches_ibfk_2
        foreign key (branch_id) references yuv_main.branches (id)
);

create index branch_id
    on yuv_main.driver_branches (branch_id);

create table yuv_main.driver_cnh_categories
(
    driver_id   bigint   not null,
    category_id smallint not null,
    primary key (driver_id, category_id),
    constraint driver_cnh_categories_cnh_categories_FK
        foreign key (category_id) references yuv_main.cnh_categories (id)
            on update cascade on delete cascade,
    constraint driver_cnh_categories_drivers_FK
        foreign key (driver_id) references yuv_main.drivers (id)
            on update cascade on delete cascade
);

create table yuv_main.driver_documents
(
    id        bigint auto_increment
        primary key,
    driver_id bigint       not null,
    filename  varchar(100) not null,
    constraint driver_documents_driver_id_FK
        foreign key (driver_id) references yuv_main.drivers (id)
);

create table yuv_main.driver_faces
(
    id          bigint auto_increment
        primary key,
    driver_id   bigint       not null,
    filename    varchar(100) not null,
    device_type varchar(50)  null,
    constraint driver_faces_driver_id_FK
        foreign key (driver_id) references yuv_main.drivers (id)
);

create table yuv_main.driver_leaderboards
(
    id         bigint auto_increment
        primary key,
    driver_id  bigint                              not null,
    score      int                                 not null,
    date       date                                not null,
    created_at timestamp default CURRENT_TIMESTAMP null,
    updated_at timestamp default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint driver_leaderboards_ibfk_1
        foreign key (driver_id) references yuv_main.drivers (id)
);

create index idx_driver_leaderboards_date
    on yuv_main.driver_leaderboards (date);

create index idx_driver_leaderboards_driver_id
    on yuv_main.driver_leaderboards (driver_id);

create index idx_driver_leaderboards_driver_id_date
    on yuv_main.driver_leaderboards (driver_id, date);

create table yuv_main.driver_scores
(
    id             bigint auto_increment
        primary key,
    driver_id      bigint                              not null,
    score          int                                 not null,
    reference_id   bigint                              not null,
    reference_type enum ('OCCURRENCE', 'ALARM')        not null,
    created_at     timestamp default CURRENT_TIMESTAMP null,
    updated_at     timestamp default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint driver_scores_ibfk_1
        foreign key (driver_id) references yuv_main.drivers (id)
);

create index idx_driver_scores_driver_id
    on yuv_main.driver_scores (driver_id);

create index drivers_customer_id_index
    on yuv_main.drivers (customer_id);

create index drivers_dealer_id_index
    on yuv_main.drivers (dealer_id);

create index drivers_name_index
    on yuv_main.drivers (name);

create table yuv_main.geofences
(
    id          bigint auto_increment
        primary key,
    name        varchar(100)                            not null,
    dealer_id   bigint                                  not null,
    customer_id bigint                                  not null,
    type        enum ('CIRCLE', 'POLYGON', 'RECTANGLE') not null,
    created_at  datetime default CURRENT_TIMESTAMP      not null,
    updated_at  datetime default CURRENT_TIMESTAMP      not null,
    constraint fk_gf_customer_id
        foreign key (customer_id) references yuv_main.customers (id),
    constraint fk_gf_dealer_id
        foreign key (dealer_id) references yuv_main.dealers (id)
);

create table yuv_main.asset_group_geofences
(
    asset_group_id bigint not null,
    geofence_id    bigint not null,
    constraint fk_agf_asset_group_id
        foreign key (asset_group_id) references yuv_main.asset_groups (id),
    constraint fk_agf_geofence_id
        foreign key (geofence_id) references yuv_main.geofences (id)
);

create table yuv_main.geofence_coordinates
(
    id          bigint auto_increment
        primary key,
    geofence_id bigint         not null,
    latitude    decimal(10, 6) not null,
    longitude   decimal(10, 6) not null,
    position    int            not null,
    constraint fk_gfc_geofence_id
        foreign key (geofence_id) references yuv_main.geofences (id)
);

create table yuv_main.occurrence_setting_parameters
(
    occurrence_setting_id bigint                              not null,
    alarm_type_id         smallint                            not null,
    period smallint not null,
    min                   smallint                            not null,
    severity              enum ('Alto', 'M�dio', 'Baixo')     not null,
    media_type            smallint default 2                  not null,
    media_channels        json     default (json_array(1, 3)) not null,
    constraint occurrence_setting_parameters_occurrence_settings_FK
        foreign key (occurrence_setting_id) references yuv_main.occurrence_settings (id)
            on update cascade on delete cascade
);

create index occurrence_setting_parameters_occurrence_setting_id_IDX
    on yuv_main.occurrence_setting_parameters (occurrence_setting_id);

create table yuv_main.schema_migrations
(
    version varchar(128) not null
        primary key
);

create table yuv_main.sim_card_carriers
(
    id   smallint    not null
        primary key,
    name varchar(50) not null
);

create table yuv_main.sim_cards
(
    id                  bigint auto_increment
        primary key,
    sim_card_carrier_id smallint     not null,
    dealer_id           bigint       not null,
    number              varchar(50)  not null,
    iccid               varchar(100) null,
    constraint sim_cards_dealers_FK
        foreign key (dealer_id) references yuv_main.dealers (id),
    constraint sim_cards_sim_card_carriers_FK
        foreign key (sim_card_carrier_id) references yuv_main.sim_card_carriers (id)
);

create table yuv_main.devices
(
    id                       bigint auto_increment
        primary key,
    dealer_id                bigint                               not null,
    device_model_id          smallint                             not null,
    sim_card_id              bigint                               null,
    imei                     varchar(100)                         not null,
    last_heartbeat           datetime                             null,
    last_gps                 datetime                             null,
    is_alarm_request_enabled tinyint(1) default 1                 not null,
    firmware_id              smallint                             null,
    is_enabled               tinyint(1) default 0                 not null,
    network_type             varchar(15)                          null,
    created_at               datetime   default CURRENT_TIMESTAMP not null,
    updated_at               datetime   default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    deleted_at               datetime                             null,
    custom_channel_names     json                                 null,
    constraint devices_dealers_FK
        foreign key (dealer_id) references yuv_main.dealers (id),
    constraint devices_device_models_FK
        foreign key (device_model_id) references yuv_main.device_models (id),
    constraint devices_firmwares_FK
        foreign key (firmware_id) references yuv_main.firmwares (id)
            on update set null on delete set null,
    constraint devices_sim_cards_FK
        foreign key (sim_card_id) references yuv_main.sim_cards (id)
            on update set null on delete set null
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.activation_history
(
    id               bigint auto_increment
        primary key,
    device_id        bigint       not null,
    dealer_id        bigint       not null,
    activation_start datetime     not null,
    activation_end   datetime     null,
    user_email_start varchar(255) not null,
    user_email_end   varchar(255) null,
    constraint activation_history_dealer_id_fkey
        foreign key (dealer_id) references yuv_main.dealers (id),
    constraint activation_history_device_id_fkey
        foreign key (device_id) references yuv_main.devices (id)
);

create index activation_history_dealer_id_idx
    on yuv_main.activation_history (dealer_id, device_id, activation_start);

create index activation_history_device_id_idx
    on yuv_main.activation_history (device_id, activation_start);

create table yuv_main.assets
(
    id             bigint auto_increment
        primary key,
    dealer_id      bigint                             not null,
    customer_id    bigint                             null,
    device_id      bigint                             null,
    identifier     varchar(100)                       not null,
    prefix         varchar(100)                       null,
    manufacturer   varchar(100)                       null,
    model          varchar(100)                       null,
    year           varchar(4)                         null,
    color          varchar(20)                        null,
    last_heartbeat datetime                           null,
    last_gps       datetime                           null,
    hourmeter      int                                null,
    odometer       int                                null,
    maintenance_id bigint unsigned                    null,
    size           enum ('SMALL', 'MEDIUM', 'LARGE')  null,
    created_at     datetime default CURRENT_TIMESTAMP not null,
    updated_at     datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    deleted_at     datetime                           null,
    constraint assets_customers_FK
        foreign key (customer_id) references yuv_main.customers (id)
            on update set null on delete set null,
    constraint assets_dealers_FK
        foreign key (dealer_id) references yuv_main.dealers (id),
    constraint assets_devices_FK
        foreign key (device_id) references yuv_main.devices (id)
            on update set null on delete set null,
    constraint assets_maintenance_id_fkey
        foreign key (maintenance_id) references yuv_main.maintenances (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.alarms
(
    id                     bigint auto_increment
        primary key,
    asset_id               bigint                               null,
    driver_id              bigint                               null,
    device_model_id        smallint                             not null,
    dealer_id              bigint                               not null,
    customer_id            bigint                               null,
    alarm_type_id          smallint                             not null,
    geofence_id            bigint                               null,
    rule_id                bigint                               null,
    device_imei            varchar(50)                          not null,
    gps_time               datetime                             not null,
    gate_time              datetime   default CURRENT_TIMESTAMP not null,
    gps_number             int                                  null,
    latitude               decimal(10, 6)                       not null,
    longitude              decimal(10, 6)                       not null,
    speed                  int                                  null,
    alarm_label            varchar(100)                         null,
    need_to_request        tinyint(1) default 0                 null,
    disable_request_reason varchar(100)                         null,
    last_file_request_time datetime                             null,
    file_request_attempts  int        default 0                 null,
    iothub_alert_type      int                                  null,
    constraint alarms_alarm_type_id_fkey
        foreign key (alarm_type_id) references yuv_main.alarm_types (id),
    constraint alarms_asset_id_fkey
        foreign key (asset_id) references yuv_main.assets (id),
    constraint alarms_customer_id_fkey
        foreign key (customer_id) references yuv_main.customers (id)
            on delete set null,
    constraint alarms_dealer_id_fkey
        foreign key (dealer_id) references yuv_main.dealers (id),
    constraint alarms_device_model_id_fkey
        foreign key (device_model_id) references yuv_main.device_models (id),
    constraint alarms_driver_id_fk
        foreign key (driver_id) references yuv_main.drivers (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.alarm_files
(
    id         bigint auto_increment
        primary key,
    alarm_id   bigint                             not null,
    file_name  varchar(100)                       not null,
    channel    varchar(10)                        null,
    created_at datetime default CURRENT_TIMESTAMP not null,
    constraint alarm_files_unique
        unique (alarm_id, file_name),
    constraint alarm_files_alarm_id_fkey
        foreign key (alarm_id) references yuv_main.alarms (id)
            on delete cascade
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index alarm_files_alarm_id_index
    on yuv_main.alarm_files (alarm_id desc, file_name asc);

create index ad_imei_gps_time_dealer_id_customer_id_alert_type_id_index
    on yuv_main.alarms (device_imei asc, gps_time desc, dealer_id asc, customer_id asc, alarm_type_id asc);

create index alarms_alarm_label_index
    on yuv_main.alarms (alarm_label);

create index alarms_alert_type_id_index
    on yuv_main.alarms (iothub_alert_type);

create index alarms_asset_id_gps_time_customer_id_alert_type_id_index
    on yuv_main.alarms (asset_id asc, gps_time desc, customer_id asc, alarm_type_id asc);

create index alarms_asset_id_gps_time_dealer_id_alert_type_id_index
    on yuv_main.alarms (asset_id asc, gps_time desc, dealer_id asc, alarm_type_id asc);

create index alarms_device_imei_gps_time_customer_id_alert_type_id_index
    on yuv_main.alarms (device_imei asc, gps_time desc, customer_id asc, alarm_type_id asc);

create index alarms_device_imei_gps_time_dealer_id_alert_type_id_index
    on yuv_main.alarms (device_imei asc, gps_time desc, dealer_id asc, alarm_type_id asc);

create index alarms_device_imei_index
    on yuv_main.alarms (device_imei asc, gps_time desc);

create index alarms_need_to_request_last_file_request_time_index
    on yuv_main.alarms (need_to_request asc, last_file_request_time desc);

create index id_gps_time_dealer_id_customer_id_alert_type_id_index
    on yuv_main.alarms (asset_id asc, gps_time desc, dealer_id asc, customer_id asc, alarm_type_id asc);

create table yuv_main.asset_group_assets
(
    asset_group_id bigint not null,
    asset_id       bigint not null,
    primary key (asset_group_id, asset_id),
    constraint asset_group_assets_asset_group_id_fk
        foreign key (asset_group_id) references yuv_main.asset_groups (id)
            on delete cascade,
    constraint asset_group_assets_asset_id_fk
        foreign key (asset_id) references yuv_main.assets (id)
            on delete cascade
);

create index assets_dealer_id_1_IDX
    on yuv_main.assets (dealer_id asc, customer_id asc, last_heartbeat desc);

create index assets_dealer_id_2_IDX
    on yuv_main.assets (dealer_id, customer_id);

create index assets_dealer_id_3_IDX
    on yuv_main.assets (dealer_id asc, last_heartbeat desc);

create index assets_dealer_id_4_IDX
    on yuv_main.assets (dealer_id asc, last_gps desc);

create table yuv_main.checklist_histories
(
    id                bigint auto_increment
        primary key,
    checklist_id      bigint                              not null,
    checklist_item_id bigint                              not null,
    driver_id         bigint                              not null,
    asset_id          bigint                              not null,
    observation       text                                null,
    image_path        varchar(200)                        null,
    optional_image    varchar(255)                        null,
    created_at        timestamp default CURRENT_TIMESTAMP null,
    updated_at        timestamp default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    is_ok             tinyint(1)                          null,
    selected_option   varchar(255)                        null,
    value             text                                null,
    constraint checklist_histories_ibfk_1
        foreign key (checklist_id) references yuv_main.checklists (id),
    constraint checklist_histories_ibfk_2
        foreign key (checklist_item_id) references yuv_main.checklist_items (id),
    constraint checklist_histories_ibfk_3
        foreign key (driver_id) references yuv_main.drivers (id),
    constraint checklist_histories_ibfk_4
        foreign key (asset_id) references yuv_main.assets (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index asset_id
    on yuv_main.checklist_histories (asset_id);

create index checklist_id
    on yuv_main.checklist_histories (checklist_id);

create index checklist_item_id
    on yuv_main.checklist_histories (checklist_item_id);

create index driver_id
    on yuv_main.checklist_histories (driver_id);

create table yuv_main.device_firmware_tasks
(
    id          bigint auto_increment
        primary key,
    device_id   bigint                                                                not null,
    task_id     varchar(255)                                                          not null,
    firmware_id smallint                                                              not null,
    status      enum ('IN_PROGRESS', 'COMPLETED', 'FAILED') default 'IN_PROGRESS'     not null,
    created_at  datetime                                    default CURRENT_TIMESTAMP not null,
    updated_at  datetime                                    default CURRENT_TIMESTAMP not null,
    constraint device_firmware_tasks_device_id_fk
        foreign key (device_id) references yuv_main.devices (id),
    constraint device_firmware_tasks_firmware_id_fk
        foreign key (firmware_id) references yuv_main.firmwares (id)
);

create index idx_dft_device_id
    on yuv_main.device_firmware_tasks (device_id);

create index idx_dft_status
    on yuv_main.device_firmware_tasks (status);

create index idx_dft_task_id
    on yuv_main.device_firmware_tasks (task_id);

create index devices_composite_2_idx
    on yuv_main.devices (imei, device_model_id, deleted_at);

create index devices_composite_idx
    on yuv_main.devices (imei, deleted_at);

create index devices_last_gps_IDX
    on yuv_main.devices (last_gps desc);

create index devices_last_heartbeat_IDX
    on yuv_main.devices (last_heartbeat desc);

create table yuv_main.driver_logins
(
    id               bigint auto_increment
        primary key,
    driver_id        bigint                             not null,
    device_id        bigint                             not null,
    asset_id         bigint                             not null,
    device_imei      varchar(50)                        not null,
    tag              varchar(100)                       not null,
    login_at         datetime                           not null,
    login_source     varchar(50)                        not null,
    login_stored_at  datetime default CURRENT_TIMESTAMP not null,
    logout_at        datetime                           null,
    logout_source    varchar(50)                        null,
    logout_stored_at datetime                           null,
    constraint driver_logins_asset_id_fk
        foreign key (asset_id) references yuv_main.assets (id),
    constraint driver_logins_device_id_fk
        foreign key (device_id) references yuv_main.devices (id),
    constraint driver_logins_driver_id_fk
        foreign key (driver_id) references yuv_main.drivers (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index driver_logins_index_1
    on yuv_main.driver_logins (driver_id asc, asset_id asc, login_at desc, logout_at desc);

create index driver_logins_index_2
    on yuv_main.driver_logins (login_stored_at desc);

create table yuv_main.drivers_assets
(
    driver_id bigint not null,
    asset_id  bigint not null,
    constraint drivers_assets_asset_id_FK
        foreign key (asset_id) references yuv_main.assets (id),
    constraint drivers_assets_driver_id_FK
        foreign key (driver_id) references yuv_main.drivers (id)
);

create table yuv_main.hik_alarms
(
    id             bigint auto_increment
        primary key,
    alarm_id       bigint                             not null,
    hik_alarm_sign varchar(100)                       not null,
    created_at     datetime default CURRENT_TIMESTAMP not null,
    constraint hik_alarms_alarm_id_fkey
        foreign key (alarm_id) references yuv_main.alarms (id)
            on delete cascade
)
    collate = utf8mb4_0900_ai_ci;

create table yuv_main.maintenance_assets
(
    id                      bigint auto_increment
        primary key,
    asset_id                bigint                                    not null,
    device_imei             varchar(50)                               not null,
    maintenance_id          bigint unsigned                           not null,
    asset_maintenance_value int                                       not null,
    asset_maintenance_type  enum ('hourmeter', 'odometer')            not null,
    status                  enum ('PENDING', 'COMPLETED', 'CANCELED') not null,
    created_at              timestamp default CURRENT_TIMESTAMP       not null,
    updated_at              timestamp default CURRENT_TIMESTAMP       not null,
    constraint maintenance_assets_asset_id
        foreign key (asset_id) references yuv_main.assets (id),
    constraint maintenance_assets_maintenance_id
        foreign key (maintenance_id) references yuv_main.maintenances (id)
);

create index maintenance_assets_asset_id_asset_maintenance_type_index
    on yuv_main.maintenance_assets (asset_id, asset_maintenance_type);

create index maintenance_assets_asset_id_asset_maintenance_type_status_index
    on yuv_main.maintenance_assets (asset_id, asset_maintenance_type, status);

create index maintenance_assets_asset_id_index
    on yuv_main.maintenance_assets (asset_id);

create table yuv_main.occurrences
(
    id                    bigint auto_increment
        primary key,
    alarm_type_id         smallint                           not null,
    asset_id              bigint                             not null,
    driver_id             bigint                             null,
    customer_id           bigint                             not null,
    dealer_id             bigint                             not null,
    occurrence_setting_id bigint                             not null,
    device_imei           varchar(50)                        not null,
    severity              enum ('Alto', 'M�dio', 'Baixo')    not null,
    first_alarm_at        datetime                           not null,
    last_alarm_at         datetime                           not null,
    limit_at              datetime                           not null,
    created_at            datetime default CURRENT_TIMESTAMP not null,
    constraint occurrences_driver_id_fk
        foreign key (driver_id) references yuv_main.drivers (id),
    constraint occurrences_ibfk_1
        foreign key (alarm_type_id) references yuv_main.alarm_types (id),
    constraint occurrences_ibfk_2
        foreign key (asset_id) references yuv_main.assets (id),
    constraint occurrences_ibfk_3
        foreign key (customer_id) references yuv_main.customers (id),
    constraint occurrences_ibfk_4
        foreign key (dealer_id) references yuv_main.dealers (id),
    constraint occurrences_ibfk_5
        foreign key (occurrence_setting_id) references yuv_main.occurrence_settings (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.occurrence_alarms
(
    occurrence_id bigint not null,
    alarm_id      bigint not null,
    primary key (occurrence_id, alarm_id),
    constraint occurrence_alarms_occurrence_id_alarm_id_unique
        unique (occurrence_id, alarm_id),
    constraint occurrence_alarms_ibfk_1
        foreign key (occurrence_id) references yuv_main.occurrences (id)
            on delete cascade,
    constraint occurrence_alarms_ibfk_2
        foreign key (alarm_id) references yuv_main.alarms (id)
            on delete cascade
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index alarm_id
    on yuv_main.occurrence_alarms (alarm_id);

create index alarm_type_id
    on yuv_main.occurrences (alarm_type_id);

create index customer_id
    on yuv_main.occurrences (customer_id);

create index dealer_id
    on yuv_main.occurrences (dealer_id);

create index occurrence_setting_id
    on yuv_main.occurrences (occurrence_setting_id);

create index occurrences_asset_id_customer_id_created_at_severity_index
    on yuv_main.occurrences (asset_id asc, customer_id asc, created_at desc, severity asc);

create index occurrences_asset_id_dealer_id_created_at_severity_index
    on yuv_main.occurrences (asset_id asc, dealer_id asc, created_at desc, severity asc);

create index occurrences_device_imei_customer_id_created_at_severity_index
    on yuv_main.occurrences (device_imei asc, customer_id desc, created_at asc, severity asc);

create index occurrences_device_imei_dealer_id_created_at_severity_index
    on yuv_main.occurrences (device_imei asc, dealer_id asc, created_at desc, severity asc);

create index occurrences_device_imei_index
    on yuv_main.occurrences (device_imei);

create table yuv_main.share_links
(
    id         bigint unsigned auto_increment
        primary key,
    asset_id   bigint                              not null,
    token      char(36)                            not null comment 'UUID v4',
    expires_at timestamp                           not null,
    created_at timestamp default CURRENT_TIMESTAMP not null,
    updated_at timestamp default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint uq_share_links_token
        unique (token),
    constraint fk_share_links_asset
        foreign key (asset_id) references yuv_main.assets (id)
            on delete cascade
)
    collate = utf8mb4_unicode_ci;

create table yuv_main.sodep_access_codes
(
    customer_id bigint      not null,
    access_code varchar(50) not null,
    primary key (customer_id, access_code),
    constraint sodep_access_codes_ibfk_1
        foreign key (customer_id) references yuv_main.customers (id)
            on delete cascade
);

create table yuv_main.sodep_pending_to_send
(
    alarm_id   bigint                              not null
        primary key,
    created_at timestamp default CURRENT_TIMESTAMP not null,
    constraint sodep_pending_to_send_ibfk_1
        foreign key (alarm_id) references yuv_main.alarms (id)
            on delete cascade
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index sodep_pending_to_send_created_at_index
    on yuv_main.sodep_pending_to_send (created_at desc);

create table yuv_main.sodep_temp
(
    alarm_id   bigint                             not null,
    created_at datetime default CURRENT_TIMESTAMP not null,
    constraint sodep_temp_alarm_id_fk
        foreign key (alarm_id) references yuv_main.alarms (id)
            on update cascade on delete cascade
);

create index sodep_temp_alarm_id_index
    on yuv_main.sodep_temp (alarm_id);

create index sodep_temp_created_at_index
    on yuv_main.sodep_temp (created_at);

create table yuv_main.streamax_alarms
(
    id                bigint auto_increment
        primary key,
    alarm_id          bigint                             not null,
    streamax_alarm_id varchar(100)                       not null,
    created_at        datetime default CURRENT_TIMESTAMP not null,
    constraint streamax_alarms_unique
        unique (alarm_id, streamax_alarm_id),
    constraint streamax_alarms_alarm_id_fkey
        foreign key (alarm_id) references yuv_main.alarms (id)
            on delete cascade
);

create index streamax_alarms_alarm_id_index
    on yuv_main.streamax_alarms (alarm_id);

create index streamax_alarms_created_at_index
    on yuv_main.streamax_alarms (created_at desc);

create index streamax_alarms_streamax_alarm_id_index
    on yuv_main.streamax_alarms (streamax_alarm_id);

create table yuv_main.system_logs
(
    id                  bigint auto_increment
        primary key,
    system_logable_id   bigint                              null,
    system_logable_type varchar(255)                        null,
    user_id             bigint                              null,
    guard_name          varchar(50)                         null,
    module_name         varchar(50)                         null,
    action              varchar(50)                         null,
    old_value           json                                null,
    new_value           json                                null,
    ip_address          varchar(50)                         null,
    created_at          timestamp default CURRENT_TIMESTAMP not null,
    updated_at          timestamp default CURRENT_TIMESTAMP not null
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.telemetries
(
    id                         int auto_increment
        primary key,
    asset_id                   bigint                             null,
    dealer_id                  bigint                             not null,
    customer_id                bigint                             null,
    device_imei                varchar(50)                        not null,
    ignition                   tinyint(1)                         null,
    latitude                   double                             not null,
    longitude                  double                             not null,
    gps_time                   datetime                           not null,
    gate_time                  datetime default CURRENT_TIMESTAMP not null,
    accelerator_pedal_position double                             null,
    engine_hourmeter           int                                null,
    odometer                   int                                null,
    engine_rpm                 int                                null,
    engine_coolant_temperature int                                null,
    engine_oil_pressure        double                             null,
    fuel_level                 double                             null,
    total_fuel_consumption     double                             null,
    reserved_p1                text                               null,
    speed                      double                             null,
    engine_torque              double                             null,
    reserved_p2                text                               null,
    engine_brake               double                             null,
    reserved_p3                text                               null,
    reserved_p4                text                               null,
    reserved_p5                text                               null,
    cruise_control_status      tinyint(1)                         null,
    clutch_status              tinyint(1)                         null,
    parking_brake_status       tinyint(1)                         null,
    service_brake_status       tinyint(1)                         null,
    constraint telemetries_unique
        unique (device_imei, gps_time),
    constraint telemetries_asset_id_fkey
        foreign key (asset_id) references yuv_main.assets (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index telemetries_asset_id_gps_time_customer_id
    on yuv_main.telemetries (asset_id asc, gps_time desc, customer_id asc);

create index telemetries_asset_id_gps_time_dealer_id
    on yuv_main.telemetries (asset_id asc, gps_time desc, dealer_id asc);

create index telemetries_asset_id_gps_time_dealer_id_customer_id
    on yuv_main.telemetries (asset_id asc, gps_time desc, dealer_id asc, customer_id asc);

create index telemetries_asset_id_index
    on yuv_main.telemetries (asset_id);

create index telemetries_device_imei_gps_time_customer_id
    on yuv_main.telemetries (device_imei asc, gps_time desc, customer_id asc);

create index telemetries_device_imei_gps_time_dealer_id
    on yuv_main.telemetries (device_imei asc, gps_time desc, dealer_id asc);

create index telemetries_device_imei_gps_time_dealer_id_customer_id
    on yuv_main.telemetries (device_imei asc, gps_time desc, dealer_id asc, customer_id asc);

create index telemetries_gate_time_index
    on yuv_main.telemetries (gate_time desc);

create index telemetries_gps_time_index
    on yuv_main.telemetries (gps_time desc);

create table yuv_main.time_zones
(
    id          smallint     not null
        primary key,
    value       varchar(25)  not null,
    add_string  varchar(25)  not null,
    description varchar(255) not null
);

create table yuv_main.user_types
(
    id   smallint    not null
        primary key,
    name varchar(20) not null
);

create table yuv_main.permission_group_user_type_x_user_type
(
    user_type_id         smallint not null,
    allowed_user_type_id smallint not null,
    constraint permission_group_user_type_x_user_type_user_types_FK
        foreign key (user_type_id) references yuv_main.user_types (id)
            on update cascade on delete cascade,
    constraint permission_group_user_type_x_user_type_user_types_FK_1
        foreign key (allowed_user_type_id) references yuv_main.user_types (id)
            on update cascade on delete cascade
);

create table yuv_main.permission_groups
(
    id              bigint auto_increment
        primary key,
    name            varchar(100)                       not null,
    user_type_id    smallint                           not null,
    dealer_id       bigint                             null,
    customer_id     bigint                             null,
    is_from_manager tinyint(1)                         not null,
    is_from_admin   tinyint(1)                         not null,
    created_at      datetime default CURRENT_TIMESTAMP not null,
    updated_at      datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    deleted_at      datetime                           null,
    constraint permission_groups_dealers_FK
        foreign key (dealer_id) references yuv_main.dealers (id)
            on update cascade on delete cascade,
    constraint permission_groups_user_types_FK
        foreign key (user_type_id) references yuv_main.user_types (id)
);

alter table yuv_main.dealers
    add constraint dealers_permission_groups_FK
        foreign key (customer_permission_group_id) references yuv_main.permission_groups (id);

create table yuv_main.permission_group_permissions
(
    permission_group_id bigint not null,
    permission_id       int    not null,
    constraint permission_group_permissions_permission_groups_FK
        foreign key (permission_group_id) references yuv_main.permission_groups (id)
            on update cascade on delete cascade,
    constraint permission_group_permissions_permissions_FK
        foreign key (permission_id) references yuv_main.permissions (id)
);

create table yuv_main.users
(
    id                       bigint auto_increment
        primary key,
    dealer_id                bigint                               null,
    customer_id              bigint                               null,
    user_type_id             smallint                             not null,
    permission_group_id      bigint                               null,
    language_id              smallint                             not null,
    time_zone_id             smallint                             not null,
    name                     varchar(100)                         not null,
    email                    varchar(100)                         not null,
    password                 varchar(255)                         not null,
    is_root                  tinyint(1) default 0                 not null,
    is_enabled               tinyint(1) default 1                 not null,
    picture                  varchar(255)                         null,
    is_first_login           tinyint(1) default 1                 not null,
    introduced_to_onboarding tinyint(1) default 0                 not null,
    created_at               timestamp  default CURRENT_TIMESTAMP not null,
    updated_at               timestamp  default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    deleted_at               timestamp                            null,
    constraint email_unique
        unique (email),
    constraint id_customers_FK
        foreign key (customer_id) references yuv_main.customers (id),
    constraint id_dealers_FK
        foreign key (dealer_id) references yuv_main.dealers (id),
    constraint id_languages_FK
        foreign key (language_id) references yuv_main.languages (id),
    constraint id_permission_groups_FK
        foreign key (permission_group_id) references yuv_main.permission_groups (id),
    constraint id_time_zones_FK
        foreign key (time_zone_id) references yuv_main.time_zones (id),
    constraint id_user_types_FK
        foreign key (user_type_id) references yuv_main.user_types (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create table yuv_main.api_keys
(
    id          int auto_increment
        primary key,
    dealer_id   bigint                              not null,
    customer_id bigint                              null,
    user_id     bigint                              not null,
    token       varchar(255)                        not null,
    jti         varchar(36)                         null,
    created_at  timestamp default CURRENT_TIMESTAMP null,
    expires_in  timestamp                           not null,
    constraint token
        unique (token),
    constraint ak_customer_id_fk
        foreign key (customer_id) references yuv_main.customers (id),
    constraint api_keys_dealer_Id
        foreign key (dealer_id) references yuv_main.dealers (id)
            on update cascade on delete cascade,
    constraint api_keys_user_id
        foreign key (user_id) references yuv_main.users (id)
            on update cascade on delete cascade
);

create table yuv_main.banners
(
    id          bigint auto_increment
        primary key,
    user_id     bigint               not null,
    title       varchar(255)         not null,
    subtitle    varchar(255)         null,
    description text                 null,
    is_active   tinyint(1) default 0 not null,
    start_date  datetime             null,
    end_date    datetime             null,
    url         varchar(255)         null,
    button      varchar(25)          null,
    created_at  timestamp            null,
    updated_at  timestamp            null,
    deleted_at  timestamp            null,
    constraint banners_user_id_foreign
        foreign key (user_id) references yuv_main.users (id)
            on update cascade on delete cascade
);

create table yuv_main.banner_user_views
(
    id         bigint auto_increment
        primary key,
    banner_id  bigint                              not null,
    user_id    bigint                              not null,
    viewed_at  timestamp default CURRENT_TIMESTAMP not null,
    created_at timestamp                           null,
    updated_at timestamp                           null,
    constraint banner_user_unique
        unique (banner_id, user_id),
    constraint banner_user_views_banner_id_foreign
        foreign key (banner_id) references yuv_main.banners (id)
            on delete cascade,
    constraint banner_user_views_user_id_foreign
        foreign key (user_id) references yuv_main.users (id)
            on delete cascade
);

create index banner_user_views_banner_id_index
    on yuv_main.banner_user_views (banner_id);

create index banner_user_views_user_id_index
    on yuv_main.banner_user_views (user_id);

create table yuv_main.banner_x_user_type
(
    banner_id    bigint   null,
    user_type_id smallint null,
    constraint banner_x_user_types_FK
        foreign key (user_type_id) references yuv_main.user_types (id)
            on update cascade on delete cascade,
    constraint banners_FK
        foreign key (banner_id) references yuv_main.banners (id)
            on update cascade on delete cascade
);

create index banners_user_id_index
    on yuv_main.banners (user_id);

create index idx_banners_active_dates
    on yuv_main.banners (is_active, start_date, end_date);

create table yuv_main.branch_users
(
    branch_id bigint not null,
    user_id   bigint not null,
    primary key (branch_id, user_id),
    constraint branch_users_id_branch_id_fk
        foreign key (branch_id) references yuv_main.branches (id)
            on delete cascade,
    constraint branch_users_user_id_fk
        foreign key (user_id) references yuv_main.users (id)
            on delete cascade
);

create table yuv_main.change_logs
(
    id         bigint auto_increment
        primary key,
    user_id    bigint                             not null,
    version    varchar(20)                        null,
    created_at datetime default CURRENT_TIMESTAMP not null,
    updated_at datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint change_logs_users_FK
        foreign key (user_id) references yuv_main.users (id)
);

create table yuv_main.change_log_items
(
    id            bigint auto_increment
        primary key,
    change_log_id bigint                             not null,
    description   text                               not null,
    created_at    datetime default CURRENT_TIMESTAMP not null,
    updated_at    datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint change_log_items_change_logs_FK
        foreign key (change_log_id) references yuv_main.change_logs (id)
            on update cascade on delete cascade
);

create table yuv_main.change_log_item_user_types
(
    change_log_item_id bigint   not null,
    user_type_id       smallint not null,
    constraint change_log_item_user_types_change_log_items_FK
        foreign key (change_log_item_id) references yuv_main.change_log_items (id)
            on update cascade on delete cascade,
    constraint change_log_item_user_types_user_types_FK
        foreign key (user_type_id) references yuv_main.user_types (id)
);

create index change_log_item_user_types_change_log_item_id_IDX
    on yuv_main.change_log_item_user_types (change_log_item_id);

create table yuv_main.command_chats
(
    id         bigint auto_increment
        primary key,
    device_id  bigint                             not null,
    user_id    bigint                             not null,
    created_at datetime default CURRENT_TIMESTAMP not null,
    constraint command_chats_devices_FK
        foreign key (device_id) references yuv_main.devices (id)
            on update cascade on delete cascade,
    constraint command_chats_users_FK
        foreign key (user_id) references yuv_main.users (id)
            on update cascade on delete cascade
);

create table yuv_main.command_chat_history
(
    id               bigint auto_increment
        primary key,
    command_chat_id  bigint                             not null,
    command_queue_id bigint                             null,
    message          text                               not null,
    origin           enum ('SERVER', 'DEVICE')          not null,
    created_at       datetime default CURRENT_TIMESTAMP not null,
    constraint command_chat_history_command_chats_FK
        foreign key (command_chat_id) references yuv_main.command_chats (id)
            on update cascade on delete cascade,
    constraint command_chat_history_command_queue_FK
        foreign key (command_queue_id) references yuv_main.command_queue (id)
            on update set null on delete set null
);

create index command_chat_history_command_chat_id_IDX
    on yuv_main.command_chat_history (command_chat_id desc, id desc);

create table yuv_main.internal_notifications
(
    id          bigint auto_increment
        primary key,
    user_id     bigint                               not null,
    title       varchar(50)                          not null,
    description varchar(512)                         not null,
    is_active   tinyint(1) default 0                 not null,
    priority    enum ('LOW', 'MEDIUM', 'HIGH')       not null,
    url         text                                 null,
    created_at  datetime   default CURRENT_TIMESTAMP not null,
    updated_at  datetime   default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP,
    constraint internal_notifications_users_FK
        foreign key (user_id) references yuv_main.users (id)
            on update cascade on delete cascade
);

create table yuv_main.internal_notification_x_user_type
(
    internal_notification_id bigint   null,
    user_type_id             smallint null,
    constraint internal_notifications_FK
        foreign key (internal_notification_id) references yuv_main.internal_notifications (id)
            on update cascade on delete cascade,
    constraint user_types_FK
        foreign key (user_type_id) references yuv_main.user_types (id)
            on update cascade on delete cascade
);

create table yuv_main.occurrence_handling
(
    id                     bigint auto_increment
        primary key,
    occurrence_id          bigint                               not null,
    driver_id              bigint                               null,
    user_id                bigint                               not null,
    assigned_alarm_type_id smallint                             null,
    handled_at             timestamp  default CURRENT_TIMESTAMP not null,
    status                 enum ('COM RISCO', 'SEM RISCO')      not null,
    observations           text                                 null,
    false_positive         tinyint(1) default 0                 not null,
    constraint occurrence_handling_ibfk_1
        foreign key (occurrence_id) references yuv_main.occurrences (id)
            on delete cascade,
    constraint occurrence_handling_ibfk_2
        foreign key (driver_id) references yuv_main.drivers (id),
    constraint occurrence_handling_ibfk_3
        foreign key (user_id) references yuv_main.users (id),
    constraint occurrence_handling_ibfk_4
        foreign key (assigned_alarm_type_id) references yuv_main.alarm_types (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index assigned_alarm_type_id
    on yuv_main.occurrence_handling (assigned_alarm_type_id);

create index driver_id
    on yuv_main.occurrence_handling (driver_id);

create index occurrence_handling_occurrence_id_index
    on yuv_main.occurrence_handling (occurrence_id desc);

create index occurrence_id
    on yuv_main.occurrence_handling (occurrence_id);

create index user_id
    on yuv_main.occurrence_handling (user_id);

create table yuv_main.occurrence_handling_history
(
    id                     bigint auto_increment
        primary key,
    occurrence_id          bigint                               not null,
    driver_id              bigint                               null,
    user_id                bigint                               not null,
    assigned_alarm_type_id smallint                             not null,
    handled_at             timestamp  default CURRENT_TIMESTAMP not null,
    status                 enum ('COM RISCO', 'SEM RISCO')      not null,
    observations           text                                 null,
    false_positive         tinyint(1) default 0                 not null,
    constraint occurrence_handling_history_ibfk_1
        foreign key (occurrence_id) references yuv_main.occurrences (id)
            on delete cascade,
    constraint occurrence_handling_history_ibfk_2
        foreign key (driver_id) references yuv_main.drivers (id),
    constraint occurrence_handling_history_ibfk_3
        foreign key (user_id) references yuv_main.users (id),
    constraint occurrence_handling_history_ibfk_4
        foreign key (assigned_alarm_type_id) references yuv_main.alarm_types (id)
) SECONDARY_ENGINE = "RAPID" SECONDARY_LOAD = "0";

create index assigned_alarm_type_id
    on yuv_main.occurrence_handling_history (assigned_alarm_type_id);

create index driver_id
    on yuv_main.occurrence_handling_history (driver_id);

create index occurrence_handling_history_occurrence_id_index
    on yuv_main.occurrence_handling_history (occurrence_id desc);

create index occurrence_id
    on yuv_main.occurrence_handling_history (occurrence_id);

create index user_id
    on yuv_main.occurrence_handling_history (user_id);

create table yuv_main.playback
(
    id                   bigint auto_increment
        primary key,
    asset_id             bigint                                  not null,
    customer_id          bigint                                  null,
    dealer_id            bigint                                  not null,
    requested_by_user_id bigint                                  not null,
    device_imei          varchar(50)                             not null,
    remote_id            varchar(255)                            null,
    requested_file_name  varchar(255)                            null,
    arrived_file_name    varchar(255)                            null,
    status               enum ('PENDING', 'AVAIABLE', 'EXPIRED') not null,
    channel              int                                     not null,
    created_at           timestamp default CURRENT_TIMESTAMP     not null,
    completed_at         timestamp                               null,
    constraint playback_ibfk_1
        foreign key (asset_id) references yuv_main.assets (id),
    constraint playback_ibfk_2
        foreign key (customer_id) references yuv_main.customers (id)
            on delete set null,
    constraint playback_ibfk_3
        foreign key (dealer_id) references yuv_main.dealers (id),
    constraint playback_ibfk_4
        foreign key (requested_by_user_id) references yuv_main.users (id)
);

create index asset_id
    on yuv_main.playback (asset_id);

create index idx_playbacks_remote_id
    on yuv_main.playback (remote_id);

create index playback_customer_id_asset_id_created_at_index
    on yuv_main.playback (customer_id asc, asset_id asc, created_at desc);

create index playback_dealer_id_asset_id_created_at_index
    on yuv_main.playback (dealer_id asc, asset_id asc, created_at desc);

create index playback_device_imei_created_at_index
    on yuv_main.playback (device_imei asc, created_at desc);

create index requested_by_user_id
    on yuv_main.playback (requested_by_user_id);

create table yuv_main.report_exports
(
    id          bigint auto_increment
        primary key,
    user_id     bigint                                  not null,
    file        varchar(100)                            null,
    report_name varchar(100)                            not null,
    file_type   varchar(10)                             not null,
    status      enum ('PENDING', 'COMPLETED', 'FAILED') not null,
    reason      text                                    null,
    created_at  datetime default CURRENT_TIMESTAMP      not null,
    updated_at  datetime default CURRENT_TIMESTAMP      not null on update CURRENT_TIMESTAMP,
    constraint report_exports_users_FK
        foreign key (user_id) references yuv_main.users (id)
);

create table yuv_main.report_export_alarms
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint    not null,
    dealer_id        bigint    null,
    customer_id      bigint    null,
    asset_ids        json      null,
    alert_type_ids   json      null,
    device_ids       json      null,
    start_date       timestamp not null,
    end_date         timestamp not null,
    customer_ids     json      null,
    branch_ids       json      null,
    constraint report_export_alarms_ibfk_1
        foreign key (report_export_id) references yuv_main.report_exports (id)
            on delete cascade,
    constraint report_export_alarms_ibfk_2
        foreign key (dealer_id) references yuv_main.dealers (id)
            on delete cascade,
    constraint report_export_alarms_ibfk_3
        foreign key (customer_id) references yuv_main.customers (id)
            on delete cascade
);

create index customer_id
    on yuv_main.report_export_alarms (customer_id);

create index dealer_id
    on yuv_main.report_export_alarms (dealer_id);

create index report_export_alarms_report_export_id_index
    on yuv_main.report_export_alarms (report_export_id desc);

create index report_export_id
    on yuv_main.report_export_alarms (report_export_id);

create table yuv_main.report_export_billings
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint not null,
    start_date       date   not null,
    end_date         date   not null,
    dealers          json   null,
    constraint report_export_id_billings
        foreign key (report_export_id) references yuv_main.report_exports (id)
            on delete cascade
);

create table yuv_main.report_export_driver
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint       not null,
    dealer_id        bigint       null,
    customer_id      bigint       null,
    search           varchar(200) null,
    constraint report_export_driver_customer_id_fkey
        foreign key (customer_id) references yuv_main.customers (id)
            on delete cascade,
    constraint report_export_driver_dealer_id_fkey
        foreign key (dealer_id) references yuv_main.dealers (id)
            on delete cascade,
    constraint report_export_driver_report_export_id_fkey
        foreign key (report_export_id) references yuv_main.report_exports (id)
            on delete cascade
);

create index report_export_driver_report_export_id_index
    on yuv_main.report_export_driver (report_export_id);

create table yuv_main.report_export_gps
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint   not null,
    asset_id         bigint   not null,
    start_date       datetime not null,
    end_date         datetime not null,
    `interval`       int      null,
    constraint report_export_gps_report_export_id_fkey
        foreign key (report_export_id) references yuv_main.report_exports (id)
            on delete cascade
);

create index report_export_gps_report_export_id_index
    on yuv_main.report_export_gps (report_export_id);

create table yuv_main.report_export_my_assets
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint       not null,
    customer_id      bigint       null,
    search           varchar(200) null,
    constraint report_export_my_assets_customers_id_fkey
        foreign key (customer_id) references yuv_main.customers (id)
            on delete cascade,
    constraint report_export_my_assets_report_export_id_fkey
        foreign key (report_export_id) references yuv_main.report_exports (id)
            on delete cascade
);

create table yuv_main.report_export_occurrences
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint      not null,
    dealer_id        bigint      null,
    customer_id      bigint      null,
    asset_ids        json        null,
    customer_ids     json        null,
    alarm_type_ids   json        null,
    start_date       datetime    not null,
    end_date         datetime    not null,
    status           varchar(20) null,
    driver_ids       json        null,
    constraint report_export_occurrences_customer_id_fkey
        foreign key (customer_id) references yuv_main.customers (id)
            on delete cascade,
    constraint report_export_occurrences_dealer_id_fkey
        foreign key (dealer_id) references yuv_main.dealers (id)
            on delete cascade,
    constraint report_export_occurrences_report_export_id_fkey
        foreign key (report_export_id) references yuv_main.report_exports (id)
            on delete cascade
);

create index report_export_occurrences_report_export_id_index
    on yuv_main.report_export_occurrences (report_export_id);

create table yuv_main.report_export_outdated
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint not null,
    dealer_id        bigint null,
    customer_id      bigint null,
    constraint report_export_outdated_customer_id_fkey
        foreign key (customer_id) references yuv_main.customers (id)
            on delete cascade,
    constraint report_export_outdated_dealer_id_fkey
        foreign key (dealer_id) references yuv_main.dealers (id)
            on delete cascade,
    constraint report_export_outdated_report_export_id_fkey
        foreign key (report_export_id) references yuv_main.report_exports (id)
            on delete cascade
);

create index report_export_outdated_report_export_id_index
    on yuv_main.report_export_outdated (report_export_id);

create table yuv_main.report_export_raw_data
(
    id               bigint auto_increment
        primary key,
    report_export_id bigint      not null,
    event            varchar(50) null,
    device_imei      varchar(30) null,
    start_date       datetime    not null,
    end_date         datetime    not null,
    constraint report_export_raw_data_report_export_id_fkey
        foreign key (report_export_id) references yuv_main.report_exports (id)
            on delete cascade
);

create index report_export_raw_data_report_export_id_index
    on yuv_main.report_export_raw_data (report_export_id);

create table yuv_main.user_completed_onboarding_tours
(
    id                 bigint unsigned auto_increment
        primary key,
    user_id            bigint          not null,
    onboarding_tour_id bigint unsigned not null,
    created_at         timestamp       null,
    updated_at         timestamp       null,
    constraint user_tour_completed_unique
        unique (user_id, onboarding_tour_id),
    constraint fk_completed_tour
        foreign key (onboarding_tour_id) references yuv_main.onboarding_tours (id)
            on delete cascade,
    constraint fk_completed_user
        foreign key (user_id) references yuv_main.users (id)
            on delete cascade
)
    collate = utf8mb4_unicode_ci;

create index idx_onboarding_tour_id
    on yuv_main.user_completed_onboarding_tours (onboarding_tour_id);

create index idx_user_id
    on yuv_main.user_completed_onboarding_tours (user_id);

create table yuv_main.user_customer_access
(
    id          bigint auto_increment
        primary key,
    user_id     bigint    not null,
    customer_id bigint    not null,
    created_at  timestamp null,
    updated_at  timestamp null,
    constraint user_customer_access_user_id_customer_id_unique
        unique (user_id, customer_id),
    constraint user_customer_access_customer_id_foreign
        foreign key (customer_id) references yuv_main.customers (id)
            on delete cascade,
    constraint user_customer_access_user_id_foreign
        foreign key (user_id) references yuv_main.users (id)
            on delete cascade
)
    collate = utf8mb4_unicode_ci;

