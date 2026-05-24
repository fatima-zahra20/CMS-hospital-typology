SELECT COUNT(*)
FROM clean_healthcare_infections
WHERE score IS NOT NULL AND score < 0 