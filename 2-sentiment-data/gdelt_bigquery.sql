DECLARE start_date DATE DEFAULT '2015-04-01';
DECLARE end_date   DATE DEFAULT '2025-10-01';

WITH time_filtered AS (
  SELECT *
  FROM `gdelt-bq.gdeltv2.gkg`
  WHERE DATE(PARSE_TIMESTAMP('%Y%m%d%H%M%S', CAST(Date AS STRING)))
        BETWEEN start_date AND end_date
),
source_filtered AS (
  SELECT *
  FROM time_filtered
  WHERE REGEXP_CONTAINS(LOWER(SourceCommonName),
      r'(bbc monitoring|alarabiya|albayan|alittihad|alkhaleej|arabianbusiness|dubaichronicle|'
      'emaratalyoum|emirates247|gulfbusiness|gulfnews|gulftoday|khaleejtimes|thearabianpost|'
      'thenationalnews|wam|aawsat|alaan|alanba|alarab|alayam|albiladpress|albiladdaily|'
      'aljazeera|aljarida|madina|marsd|alriyadh|alroya|seyassah|sharq|alsaudigazette|'
      'almowaten|alqabas|alraimedia|asharq|independentarabia|kuna|kunta|nytimes\\.com|'
      'washingtonpost\\.com|wsj\\.com|usatoday\\.com|latimes\\.com|chicagotribune\\.com|'
      'bostonglobe\\.com|houstonchronicle\\.com|abcnews\\.go\\.com|cbsnews\\.com|nbcnews\\.com|'
      'pbs\\.org|foxnews\\.com|cnn\\.com|msnbc\\.com|apnews\\.com|reuters\\.com|bloomberg\\.com|'
      'marketwatch\\.com|barrons\\.com|cnbc\\.com|forbes\\.com|businessinsider\\.com|npr\\.org|'
      'publicradioexchange\\.org|theatlantic\\.com|time\\.com|newsweek\\.com|newyorker\\.com|'
      'economist\\.com|motherjones\\.com|politico\\.com|vox\\.com|huffpost\\.com|axios\\.com|'
      'buzzfeednews\\.com|slate\\.com|propublica\\.org|fivethirtyeight\\.com|thehill\\.com|'
      'realclearpolitics\\.com|miamiherald\\.com|inquirer\\.com|startribune\\.com|seattletimes\\.com|'
      'tampabay\\.com|sfchronicle\\.com|freep\\.com|dallasnews\\.com|ajc\\.com|denverpost\\.com|'
      'publicintegrity\\.org|insideclimatenews\\.org|khn\\.org|politifact\\.com|factcheck\\.org|'
      'fortune\\.com|fastcompany\\.com|techcrunch\\.com|theverge\\.com|c-span\\.org|cheddar\\.com)')
),
theme_filtered AS (
  SELECT *
  FROM source_filtered
  WHERE REGEXP_CONTAINS(V2Themes,
      r'(ECON_TAXATION|ECON_STOCKMARKET|ECON_INFLATION|ECON_DEBT|ECON_CENTRALBANK|ECON_BITCOIN|'
      'ECON_HOUSING_PRICES|ECON_ENTREPRENEURSHIP|ECON_INTEREST_RATES|ECON_WORLDCURRENCIES_DOLLAR|'
      'ECON_WORLDCURRENCIES_EURO|ECON_CURRENCY_EXCHANGE_RATE|ECON_OILPRICE|ECON_BOYCOTT|'
      'ECON_BANKRUPTCY|ECON_ELECTRICALGENERATION)')
),
country_filtered AS (
  SELECT *
  FROM theme_filtered
  WHERE REGEXP_CONTAINS(LOWER(V2Locations), r'(united arab emirates|\\buae\\b)')
),
final AS (
  SELECT
    Extras                                                   AS raw_extras,
    LOWER(SourceCommonName)                                  AS clean_source,
    SharingImage                                             AS clean_image,
    REGEXP_EXTRACT(Extras, r'<PAGE_TITLE>(.*?)</PAGE_TITLE>') AS clean_title,
    DocumentIdentifier                                       AS clean_link,
    PARSE_TIMESTAMP('%Y%m%d%H%M%S', CAST(Date AS STRING))    AS Timestamp,
    CAST(SPLIT(V2Tone, ',')[OFFSET(0)] AS FLOAT64)           AS clean_tone,
    CAST(SPLIT(V2Tone, ',')[OFFSET(1)] AS FLOAT64)           AS positive_score,
    CAST(SPLIT(V2Tone, ',')[OFFSET(2)] AS FLOAT64)           AS negative_score,
    CAST(SPLIT(V2Tone, ',')[OFFSET(3)] AS FLOAT64)           AS polarity,
    CAST(SPLIT(V2Tone, ',')[OFFSET(4)] AS FLOAT64)           AS activity_ref_density,
    CAST(SPLIT(V2Tone, ',')[OFFSET(5)] AS FLOAT64)           AS self_group_ref_density,
    CAST(SPLIT(V2Tone, ',')[OFFSET(6)] AS INT64)             AS word_count,
    ARRAY_LENGTH(ARRAY(SELECT x FROM UNNEST(SPLIT(V2Counts, ';')) x WHERE x <> '')) AS num_mentions,
    V2Locations                                              AS clean_locations,
    REGEXP_CONTAINS(V2Themes, 'ECON_TAXATION')               AS ECON_TAXATION,
    REGEXP_CONTAINS(V2Themes, 'ECON_STOCKMARKET')            AS ECON_STOCKMARKET,
    REGEXP_CONTAINS(V2Themes, 'ECON_INFLATION')              AS ECON_INFLATION,
    REGEXP_CONTAINS(V2Themes, 'ECON_DEBT')                   AS ECON_DEBT,
    REGEXP_CONTAINS(V2Themes, 'ECON_CENTRALBANK')            AS ECON_CENTRALBANK,
    REGEXP_CONTAINS(V2Themes, 'ECON_BITCOIN')                AS ECON_BITCOIN,
    REGEXP_CONTAINS(V2Themes, 'ECON_HOUSING_PRICES')         AS ECON_HOUSING_PRICES,
    REGEXP_CONTAINS(V2Themes, 'ECON_ENTREPRENEURSHIP')       AS ECON_ENTREPRENEURSHIP,
    REGEXP_CONTAINS(V2Themes, 'ECON_INTEREST_RATES')         AS ECON_INTEREST_RATES,
    REGEXP_CONTAINS(V2Themes, 'ECON_WORLDCURRENCIES_DOLLAR') AS ECON_WORLDCURRENCIES_DOLLAR,
    REGEXP_CONTAINS(V2Themes, 'ECON_WORLDCURRENCIES_EURO')   AS ECON_WORLDCURRENCIES_EURO,
    REGEXP_CONTAINS(V2Themes, 'ECON_CURRENCY_EXCHANGE_RATE') AS ECON_CURRENCY_EXCHANGE_RATE,
    REGEXP_CONTAINS(V2Themes, 'ECON_OILPRICE')               AS ECON_OILPRICE,
    REGEXP_CONTAINS(V2Themes, 'ECON_BOYCOTT')                AS ECON_BOYCOTT,
    REGEXP_CONTAINS(V2Themes, 'ECON_BANKRUPTCY')             AS ECON_BANKRUPTCY,
    REGEXP_CONTAINS(V2Themes, 'ECON_ELECTRICALGENERATION')   AS ECON_ELECTRICALGENERATION,
    REGEXP_CONTAINS(LOWER(V2Locations), 'united arab emirates|\\buae\\b') AS `United Arab Emirates`
  FROM country_filtered
)
SELECT *
FROM final;
