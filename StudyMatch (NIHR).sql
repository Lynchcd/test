SELECT
    COUNT(volunteer.id)
FROM
    study
    JOIN volunteer
    JOIN studystatus
    JOIN person
    JOIN study_site
    JOIN demographic
    LEFT JOIN study_enrolment ON (
        volunteer.id = study_enrolment.volunteer_id
        AND study.id = study_enrolment.study_id
    )
    LEFT JOIN volunteer_study_interest ON (
        volunteer.id = volunteer_study_interest.volunteer_id
        AND volunteer_study_interest.study_id = study.id
    )
    LEFT JOIN study_site_region ON (study_site_region.studysite_id = study_site.id)
WHERE
    (volunteer.id = demographic.volunteer_id)
    AND (volunteer.id = volunteer.id)
    AND (demographic.volunteer_id = volunteer.id)
    AND (study.id = 539)
    AND (
        studystatus.id = study_site.studystatus_id
        AND (
            studystatus.tags = 'OPEN'
            OR (
                studystatus.tags = 'SUSPENDED'
                AND (
                    volunteer_study_interest.volunteer_id IS NOT NULL
                    OR study_enrolment.volunteer_id IS NOT NULL
                )
            )
        )
    )
    AND (volunteer.person_id = person.id)
    AND (study_site.study_id = study.id)
    AND (
        (
            volunteer_study_interest.volunteer_id IS NOT NULL
        )
        OR (
            (
                study_site.radius IS NOT NULL
                AND radius > (
                    SELECT
                        ROUND(
                            3959 * acos(
                                cos(radians(hospital_trusts.geo_latitude)) * cos(radians(demographic.latitude)) * cos(
                                    radians(demographic.longitude) - radians(hospital_trusts.geo_longitude)
                                ) + sin(radians(hospital_trusts.geo_latitude)) * sin(radians(demographic.latitude))
                            ),
                            2
                        )
                    FROM
                        hospital_trusts
                    WHERE
                        hospital_trusts.id = study_site.hospital_trust_id
                )
            )
            OR (
                study_site_region.region_id IS NOT NULL
                AND study_site.radius IS NULL
                AND study_site_region.region_id = demographic.region_id
            )
            OR (
                study_site.postcodes IS NOT NULL
                AND study_site.radius IS NULL
                AND study_site_region.region_id IS NULL
                AND study_site.postcodes LIKE CONCAT('%,', person.postcode_prefix, '%')
            )
            OR (
                study_site_region.region_id IS NULL
                AND study_site.radius IS NULL
                AND study_site.postcodes IS NULL
            )
            OR (
                study_site.postcodes IS NOT NULL
                AND study_site.radius IS NULL
                AND study_site_region.region_id IS NULL
                AND study_site.postcodes LIKE CONCAT(person.postcode_prefix, '%')
            )
        )
    )
    AND (
        study.is_deleted IS NULL
        OR study.is_deleted = 0
    )
    AND (
        ((person.sex_id IN (:personsex0x0)))
        AND ((person.gender_id IN (:persongender0x1)))
        AND (volunteer.id = :volunteerId0)
        AND (
            demographic.declaration_accepted_date IS NOT NULL
        )
        AND (volunteer.is_soft_deleted = false)
    )