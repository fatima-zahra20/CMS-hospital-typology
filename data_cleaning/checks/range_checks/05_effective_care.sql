SELECT COUNT(*)
FROM clean_timely_effective_care
WHERE score IS NOT NULL AND score < 0
OR   sample IS NOT NULL AND sample < 0