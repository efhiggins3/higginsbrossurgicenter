########################
# UPLOAD TO BLOOMERANG #
########################
/* FOR PAYPAL:

=REGEXREPLACE(B25,"[A-Za-z]","")
*/

# Individuals with Donations.csv
SELECT
  m.account_number AS Account_Number,
  d.name_prefix AS Title,
  d.first_name AS First_Name,
  d.middle_initial AS Middle_Name,
  d.last_name AS Last_Name,
  "" AS Suffix,
  CONCAT(
    IF(d.company_care_of IS NULL, d.mailing_address, d.company_care_of),
    IF(d.company_care_of IS NULL, "", d.mailing_address)
  ) AS Home_Address,
  d.city AS Home_City,
  d.state AS Home_State,
  d.zip_code AS Home_Zip_Code,
  "" AS Work_Address,
  "" AS Work_City,
  "" AS Work_State,
  "" AS Work_Zip_Code,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, "", CAST(d.phone_number AS STRING)) AS Home_phone,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, CAST(d.phone_number AS STRING), "") AS Work_phone,
  "" AS Mobile,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, "", d.email_address) AS Home_email,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, d.email_address, "") AS Work_Email,
  CONCAT(
    SUBSTR(CAST(t.date AS string),6,2),
    "/", SUBSTR(CAST(t.date AS string),-2),
    "/", SUBSTR(CAST(t.date AS string),0,4)
  ) AS Date,
  t.donation_amount AS Amount,
  "Unrestricted" AS Fund,
  "" AS Campaign,
  "" AS Appeal,
  "" AS Method,
  "" AS Acknowledged,
  "" AS Note,
  IF(t.donations_cross_ref > 800000, "PayPal", "GKCCF") AS Donation_Made_Via,
  t.transaction_number AS Bigquery_Transaction_Number,
  t.donations_cross_ref AS Original_Donations_Log_Cross_Ref
FROM
  donations.transactions t
  LEFT JOIN individuals.donors d ON
    (t.donor_id = d.donor_id)
  LEFT JOIN
    (SELECT
      d.donor_id AS bigquery_id,
      COALESCE(
        b_fl_name.AccountNumber,
        IF(d.is_company = TRUE OR d.is_foundation = TRUE, b_comp_name.AccountNumber, NULL),
        CASE
          WHEN d.donor_id = 188 THEN 192
          WHEN d.donor_id = 1003 THEN 242
          WHEN d.donor_id = 1011 THEN 347
          WHEN d.donor_id = 10081 THEN 253
          WHEN d.donor_id = 1000003 THEN 262
          WHEN d.donor_id = 1000026 THEN 285
          WHEN d.donor_id = 1000081 THEN 254
          WHEN d.donor_id = 1000083 THEN 345
          ELSE NULL
        END
      ) AS account_number
    FROM
      individuals.donors d
      LEFT JOIN individuals.bloomerang_export b_fl_name ON
        (d.first_name = b_fl_name.First
         AND d.last_name = b_fl_name.Last)
      LEFT JOIN individuals.bloomerang_export b_comp_name ON
        (d.company_name = b_comp_name.Employer)
    ) m ON
    (t.donor_id = m.bigquery_id)
WHERE
  t.transaction_number NOT IN
    (SELECT Custom__Bigquery_Transaction_Number
     FROM donations.bloomerang_export
     GROUP BY 1)
  AND NOT(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE)
ORDER BY t.date ASC, t.donation_amount DESC



# Organizations with Donations.csv
SELECT
  m.account_number AS Account_Number,
  d.company_name AS Organization_Name,
  d.name_prefix AS Title,
  d.first_name AS First_Name,
  d.middle_initial AS Middle_Name,
  d.last_name AS Last_Name,
  "" AS Suffix,
  CONCAT(
    IF(d.company_care_of IS NULL, d.mailing_address, d.company_care_of),
    IF(d.company_care_of IS NULL, "", d.mailing_address)
  ) AS Home_Address,
  d.city AS Home_City,
  d.state AS Home_State,
  d.zip_code AS Home_Zip_Code,
  "" AS Work_Address,
  "" AS Work_City,
  "" AS Work_State,
  "" AS Work_Zip_Code,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, "", CAST(d.phone_number AS STRING)) AS Home_phone,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, CAST(d.phone_number AS STRING), "") AS Work_phone,
  "" AS Mobile,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, "", d.email_address) AS Home_email,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, d.email_address, "") AS Work_Email,
  CONCAT(
    SUBSTR(CAST(t.date AS string),6,2),
    "/", SUBSTR(CAST(t.date AS string),-2),
    "/", SUBSTR(CAST(t.date AS string),0,4)
  ) AS Date,
  t.donation_amount AS Amount,
  "Unrestricted" AS Fund,
  "" AS Campaign,
  "" AS Appeal,
  "" AS Method,
  "" AS Acknowledged,
  "" AS Note,
  IF(t.donations_cross_ref > 800000, "PayPal", "GKCCF") AS Donation_Made_Via,
  t.transaction_number AS Bigquery_Transaction_Number,
  t.donations_cross_ref AS Original_Donations_Log_Cross_Ref
FROM
  donations.transactions t
  LEFT JOIN individuals.donors d ON
    (t.donor_id = d.donor_id)
  LEFT JOIN
    (SELECT
      d.donor_id AS bigquery_id,
      COALESCE(
        b_fl_name.AccountNumber,
        IF(d.is_company = TRUE OR d.is_foundation = TRUE, b_comp_name.AccountNumber, NULL),
        CASE
          WHEN d.donor_id = 188 THEN 192
          WHEN d.donor_id = 1003 THEN 242
          WHEN d.donor_id = 1011 THEN 347
          WHEN d.donor_id = 10081 THEN 253
          WHEN d.donor_id = 1000003 THEN 262
          WHEN d.donor_id = 1000026 THEN 285
          WHEN d.donor_id = 1000081 THEN 254
          WHEN d.donor_id = 1000083 THEN 345
          ELSE NULL
        END
      ) AS account_number
    FROM
      individuals.donors d
      LEFT JOIN individuals.bloomerang_export b_fl_name ON
        (d.first_name = b_fl_name.First
         AND d.last_name = b_fl_name.Last)
      LEFT JOIN individuals.bloomerang_export b_comp_name ON
        (d.company_name = b_comp_name.Employer)
    ) m ON
    (t.donor_id = m.bigquery_id)
WHERE
  t.transaction_number NOT IN
    (SELECT Custom__Bigquery_Transaction_Number
     FROM donations.bloomerang_export
     GROUP BY 1)
  AND (IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE)
ORDER BY t.date ASC, t.donation_amount DESC
;



# Updating specific custom events
SELECT
  m.account_number AS Account_Number,
  name_prefix AS Name_Title,
  is_board_member,
  is_volunteer,
  t.donor_id AS bigquery_id
FROM
  individuals.donors t
  INNER JOIN
    (SELECT
      d.donor_id AS bigquery_id,
      COALESCE(
        b_fl_name.AccountNumber,
        IF(d.is_company = TRUE OR d.is_foundation = TRUE, b_comp_name.AccountNumber, NULL),
        CASE
          WHEN d.donor_id = 188 THEN 192
          WHEN d.donor_id = 1003 THEN 242
          WHEN d.donor_id = 1011 THEN 347
          WHEN d.donor_id = 10081 THEN 253
          WHEN d.donor_id = 1000003 THEN 262
          WHEN d.donor_id = 1000026 THEN 285
          WHEN d.donor_id = 1000081 THEN 254
          WHEN d.donor_id = 1000083 THEN 345
          ELSE NULL
        END
      ) AS account_number
    FROM
      individuals.donors d
      LEFT JOIN individuals.bloomerang_export b_fl_name ON
        (d.first_name = b_fl_name.First
         AND d.last_name = b_fl_name.Last)
      LEFT JOIN individuals.bloomerang_export b_comp_name ON
        (d.company_name = b_comp_name.Employer)
    ) m ON
    (t.donor_id = m.bigquery_id)
WHERE
  m.account_number IS NOT NULL
  AND
    (name_prefix IS NOT NULL
     OR is_board_member IS NOT NULL
     OR is_volunteer IS NOT NULL
     OR t.donor_id IS NOT NULL
     )
ORDER BY 1 ASC
;
