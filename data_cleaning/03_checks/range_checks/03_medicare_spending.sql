SELECT COUNT(*) AS unusual_count
FROM clean_medicare_spending
WHERE avg_spd_ep_hospital IS NOT NULL AND avg_spd_ep_hospital    < 0
   OR avg_spd_ep_state    IS NOT NULL AND avg_spd_ep_state       < 0
   OR avg_spd_ep_national IS NOT NULL AND avg_spd_ep_national    < 0
   OR pct_spend_hospital    NOT BETWEEN 0 AND 100
   OR pct_spend_state       NOT BETWEEN 0 AND 100
   OR pct_spend_national    NOT BETWEEN 0 AND 100
   