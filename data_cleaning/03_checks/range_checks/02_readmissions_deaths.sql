-- Score is a rate; most measures are percentages [0, 100],
-- but PSI_04 is deaths per 1,000 surgical discharges (different scale)
SELECT COUNT(*) AS bad_score
FROM clean_readmissions_and_deaths
WHERE score IS NOT NULL 
  AND measure_id != 'PSI_04'   -- excluded: per-1,000 scale, not percentage
  AND (score < 0 OR score > 100);