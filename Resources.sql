/*

This query retrieves resources marked with "free_logged_out" as 1 and either
with "free_logged_in" as 0 or not present in the resource. It aims to identify
resources incorrectly marked as requiring payment when they should be free.
The query only includes approved resources that are part of a bundle,
as resources not included in any bundle are accessible and not behind a paywall.

Tables used:
twinkl.twinkl_resource_extra
twinkl.twinkl_resource
dx_resource

*/

SELECT re.resource_id,
       r.title,
       CONCAT('https://www.twinkl.com/resource/', r.friendly_url) AS url,
       r.redirect_url
FROM twinkl.twinkl_resource_extra AS re
JOIN twinkl.twinkl_resource AS r ON re.resource_id = r.id
LEFT JOIN (
    SELECT resource_id,
           bundle_id,
           resource_package
    FROM dx_resource
) AS dx ON re.resource_id = dx.resource_id
WHERE re.`key` = 'free_logged_out' AND re.value = 1 -- free_logged_out is 1
  AND re.resource_id NOT IN ( -- selecting resources where free_logged in is either 0 or doesn't exist
    SELECT resource_id
    FROM twinkl.twinkl_resource_extra
    WHERE `key` = 'free_logged_in' AND value = 1
  )
	AND dx.bundle_id IS NOT NULL -- resource is part of a bundle
	AND r.approved = 1; -- only looking at approved resources