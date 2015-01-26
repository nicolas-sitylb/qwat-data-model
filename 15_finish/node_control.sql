CREATE OR REPLACE VIEW qwat_od.vw_node_control AS 
	/* Node with undefined types */
	SELECT 'Node with undefined type' AS problem, id, 'node id' AS comment 
		FROM qwat_od.node 
		WHERE _type IS NULL 
	UNION
	/* Node with no pipe/valve connected */
	SELECT 'Node with no pipe connected' AS problem, id, 'node id' AS comment 
		FROM qwat_od.node 
		WHERE node.id NOT IN (SELECT DISTINCT(id_node_a) FROM qwat_od.pipe) 
		AND   node.id NOT IN (SELECT DISTINCT(id_node_b) FROM qwat_od.pipe)
	UNION
	/* Pipe with unreferenced node*/
	/*SELECT 'Pipe with unreferenced node' AS problem, id, 'pipe id' AS comment
		FROM qwat_od.pipe 
		WHERE id_node_a NOT IN (SELECT id FROM qwat_od.node) 
		AND   id_node_b NOT IN (SELECT id FROM qwat_od.node)
	UNION
	*/
	/* Valve with unreferenced node*/
	/*
	SELECT 'Valve with unreferenced node' AS problem, id, 'valve id' AS comment
		FROM qwat_od.valve 
		WHERE id_node NOT IN (SELECT id FROM qwat_od.node) 
	UNION
	*/
	/* Nodes which are too close */
	SELECT 'Too close node' AS problem, a.id, 'Distance: ' || ST_Distance(a.geometry,b.geometry)::decimal(6,4) || 'Position: ' || ST_X(a.geometry) || ' ' || ST_Y(a.geometry) AS comment
		FROM qwat_od.node a, qwat_od.node b
		WHERE a.id != b.id 
		AND ST_DWithin(a.geometry,b.geometry,0.004)
	UNION
	/* Pipes without node(s) */
	SELECT 'Pipes without node(s)' AS problem, id, 'pipe id' AS comment
		FROM qwat_od.pipe 
		WHERE id_node_a IS NULL 
		OR    id_node_b IS NULL
	UNION
	/* Non up-to-date geometries */
	SELECT 'Non up-to-date altitudes' AS problem, COUNT(id)::integer AS id, 'number of node' AS comment
		FROM qwat_od.node
		WHERE altitude_dtm IS NULL
	/* */
	ORDER BY problem
	;




