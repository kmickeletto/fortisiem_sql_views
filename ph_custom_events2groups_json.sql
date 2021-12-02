-- View: public.ph_custom_events2groups_json

-- DROP VIEW public.ph_custom_events2groups_json;

CREATE OR REPLACE VIEW public.ph_custom_events2groups_json
 AS
 WITH cte AS (
         SELECT sub_1.path[0:sub_1.i - 1] AS path,
            sub_1.i - 1 AS i,
            jsonb_object_agg(sub_1.path[sub_1.i], sub_1.event_types) AS val
           FROM ( SELECT ph_custom_events2groups.path,
                    cardinality(ph_custom_events2groups.path) AS i,
                    jsonb_agg(ph_custom_events2groups.event_type) AS event_types
                   FROM ph_custom_events2groups
                  GROUP BY ph_custom_events2groups.path
                  ORDER BY (cardinality(ph_custom_events2groups.path)) DESC) sub_1
          GROUP BY (sub_1.path[0:sub_1.i - 1]), (sub_1.i - 1)
        )
 SELECT jsonb_pretty(jsonb_object_agg(sub.path1, sub.val))::jsonb AS result
   FROM ( SELECT four_2.path1,
            jsonb_object_agg(four_2.path2, four_2.val) AS val
           FROM ( SELECT four_1.path1,
                    four_1.path2,
                    jsonb_object_agg(four_1.path3, four_1.val) AS val
                   FROM ( SELECT cte.path[1] AS path1,
                            cte.path[2] AS path2,
                            cte.path[3] AS path3,
                            jsonb_object_agg(cte.path[4], cte.val) AS val
                           FROM cte
                          WHERE cte.i = 4
                          GROUP BY (cte.path[1]), (cte.path[2]), (cte.path[3])) four_1
                  GROUP BY four_1.path1, four_1.path2) four_2
          GROUP BY four_2.path1
        UNION ALL
         SELECT three_1.path1,
            jsonb_object_agg(three_1.path2, three_1.val) AS val
           FROM ( SELECT cte.path[1] AS path1,
                    cte.path[2] AS path2,
                    jsonb_object_agg(cte.path[3], cte.val) AS val
                   FROM cte
                  WHERE cte.i = 3
                  GROUP BY (cte.path[1]), (cte.path[2])) three_1
          GROUP BY three_1.path1
        UNION ALL
         SELECT cte.path[1] AS key,
            jsonb_object_agg(cte.path[2], cte.val) AS val
           FROM cte
          WHERE cte.i = 2
          GROUP BY (cte.path[1])
        UNION ALL
         SELECT cte.path[1] AS path,
            cte.val
           FROM cte
          WHERE cte.i = 1) sub;

ALTER TABLE public.ph_custom_events2groups_json
    OWNER TO phoenix;

