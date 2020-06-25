#################
# INITIAL SETUP #
#################


# Output transactions

SELECT
  t.donor_id AS account_number,
  d.first_name AS first_name,
  d.last_name AS last_name,
  d.company_name AS organization_or_company_name,
  t.date AS date,
  t.donation_amount AS amount,
  "" AS non_deductable_amount,
  "Unrestricted" AS fund,
  "" AS campaign,
  "" AS appeal,
  IF(t.donations_cross_ref > 800000, "PayPal", "GKCCF") AS transaction_method,
  "" AS check_date,
  "" AS check_number,
  "" AS in_kind_type,
  "" AS in_kind_fair_market_value,
  "" AS in_kind_description,
  "" AS transaction_notes,
# Custom fields:
  t.transaction_number AS bigquery_transaction_number,
  t.donations_cross_ref AS original_donations_log_cross_ref
FROM
  donations.transactions t
  LEFT JOIN individuals.donors d ON
    (t.donor_id = d.donor_id)
ORDER BY t.date ASC, t.donation_amount DESC
;


# Output constituents
WITH spouse_mapping AS (
    SELECT
      mailing_address,
      COUNT(DISTINCT donor_id) donor_count,
      MIN(donor_id) AS donor_id_1,
      MAX(donor_id) AS donor_id_2
    FROM individuals.donors
    WHERE mailing_address NOT IN (
        # Ignore these shared addresses:
        "1055 Broadway Blvd., Suite 130",
        "115 Madison Road",
        "5801 Ward Parkway"
      )
    GROUP BY 1
    HAVING donor_count > 1
)
SELECT
  d.donor_id AS account_number,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, "Organization", "Individual") AS account_type,
  "Active" AS status,
  "" AS name_prefix,
  d.first_name AS first_name,
  d.middle_initial AS middle_name,
  d.last_name AS last_name,
  "" AS name_suffix,

  # Omni-directional spouse mapping:
  "" AS spouse_name_prefix,
  COALESCE(sm1_d.first_name, sm2_d.first_name, "") AS spouse_first_name,
  COALESCE(sm1_d.middle_initial, sm2_d.middle_initial, "")AS spouse_middle_name,
  COALESCE(sm1_d.last_name, sm2_d.last_name, "")AS spouse_last_name,
  "" AS spouse_name_suffix,

  d.company_name AS organization_or_company_name,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, "Work", "Home") AS addres_type_1,
  IF(d.company_care_of IS NULL, d.mailing_address, d.company_care_of) AS address_1_line_1,
  IF(d.company_care_of IS NULL, "", d.mailing_address) AS address_1_line_2,
  d.city AS city_1,
  d.state AS state_1,
  d.zip_code AS postal_code_1,
  d.country AS country_1,
  "" AS addres_type_2,
  "" AS address_2_line_1,
  "" AS address_2_line_2,
  "" AS city_2,
  "" AS state_2,
  "" AS postal_code_2,
  "" AS country_2,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, "Work", "Home") AS phone_type_1,
  d.phone_number AS phone_number_1,
  "" AS phone_extension_1,
  "" AS phone_type_2,
  "" AS phone_number_2,
  "" AS phone_extension_2,
  "" AS phone_type_3,
  "" AS phone_number_3,
  "" AS phone_extension_3,
  IF(IFNULL(d.is_company,FALSE) = TRUE OR IFNULL(d.is_foundation,FALSE) = TRUE, "Work", "Home") AS email_type_1,
  d.email_address AS email_1,
  "" AS email_type_2,
  "" AS email_2,
  "" AS email_type_3,
  "" AS email_3,
  "" AS job_title,
  "" AS gender,
  "" AS birthdate,
  "" AS website,
  "" AS facebook_url,
  "" AS twitter_handle,
  "" AS linkedin_url,
  "" AS preferred_channel,
  "" AS do_not_call,
  "" AS do_not_mail,
  "" AS opted_out_of_mass_email,
  "" AS constituent_notes,
# Custom fields:
  m.LEID AS mailchimp_leid,
  m.EUID AS mailchimp_euid,
  CASE
    WHEN IFNULL(d.is_company,FALSE) = TRUE THEN "Company"
    WHEN IFNULL(d.is_foundation,FALSE) = TRUE THEN "Foundation"
    ELSE ""
  END AS company_type
FROM
  individuals.donors d
  LEFT JOIN individuals.mailchimp_email m ON
    (d.email_address = m.Email_Address)
# Spouse mapping 1->2
  LEFT JOIN spouse_mapping sm1 ON
    (d.donor_id = sm1.donor_id_1)
  LEFT JOIN individuals.donors sm1_d ON
    (sm1.donor_id_2 = sm1_d.donor_id)
# Spouse mapping 2->1
  LEFT JOIN spouse_mapping sm2 ON
    (d.donor_id = sm2.donor_id_2)
  LEFT JOIN individuals.donors sm2_d ON
    (sm2.donor_id_1 = sm2_d.donor_id)
ORDER BY d.donor_id ASC
;
