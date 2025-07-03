-- Inserts for content_type
INSERT INTO content_type (content_type_id, content_ty_name, additional_info) VALUES
    (1, 'Film',            'A motion picture'),
    (2, 'Series',          'Series'),
    (3, 'Season',          'Season of a series'),
    (4, 'Episode',         'Episode of a series'),
    (5, 'Special Feature', 'Special content related to a stream'),
    (6, 'Live Stream',     'Live streaming content');

-- Inserts for category
INSERT INTO category (category_id, name) VALUES
    (70, 'Instant Cinema'),
    (80, 'National Sports'),
    (90, 'Frontstage');

-- Inserts for service_type
INSERT INTO service_type (service_type_id, service_type_name) VALUES
    (1, 'Subscription'),
    (2, 'Package'),
    (3, 'Spot Watching');

-- Inserts for subscription
INSERT INTO subscription (subscr_id, subscr_name, additional_info, price) VALUES
    (1, 'Free Trial', '„Basic“ for free, for one month (with ads)',    0.00),
    (2, 'Basic',      'all content with ads',                          9.99),
    (3, 'Normal',     'all content without ads',                      19.99),
    (4, 'Premium',    'All you can stream (all Packages except for Live-Streams and soccer)', 69.99);

-- Inserts for package
INSERT INTO package (package_id, category_id, additional_info, price) VALUES
    (1, 70, 'Instant Cinema: Movies that have just been in theaters',                                           10.00),
    (2, 15, 'Sports except sports live streams',                                                                   5.00),
    (3, 80, 'National Sports: Region-dependent live streams for soccer, football, cricket, etc.',                 20.00),
    (4, 90, 'Frontstage: Live streams of concerts, festivals, opera, etc.',                                       10.00);

-- Inserts for video_quality
INSERT INTO video_quality (video_quality_id, vidquality_label, vidquality_descr) VALUES
    (1, 'SD', 'Standard Definition'),
    (2, 'HD', 'High Definition, 1080p HD'),
    (3, '4K', '4K Ultra High Definition (UHD-1)'),
    (4, '8K', '8K Ultra High Definition (UHD-2)');

-- Inserts for video_quality_price
INSERT INTO video_quality_price (video_quality_id, service_type_id, vid_quality_price) VALUES
    (1, 1, 0.00),
    (1, 2, 0.00),
    (1, 3, 0.00),
    (2, 1, 3.00),
    (2, 2, 1.00),
    (2, 3, 0.50),
    (3, 1, 4.00),
    (3, 2, 1.50),
    (3, 3, 0.70),
    (4, 1, 5.00),
    (4, 2, 2.00),
    (4, 3, 1.00);

-- Inserts for franchise
INSERT INTO franchise (franchise_id, franchise_name, franchise_descr) VALUES
    (1, 'Marbel Media Multiverse', 'A media franchise in a multi-universe centered on a series of superhero films and series based on Marbel Comics.'),
    (2, 'Stellar Wars',            'A space opera franchise spanning around a classic trilogy, added preqeust, sequeals, series, and sin-off movies.'),
    (3, 'Harold Plotter',          'A fantasy media franchise and wizarding world.');
