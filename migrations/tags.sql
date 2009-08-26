--
-- PostgreSQL database dump
--

-- Started on 2009-08-26 01:15:42 EDT

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- TOC entry 1786 (class 0 OID 0)
-- Dependencies: 1508
-- Name: tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: da01
--

SELECT pg_catalog.setval('tags_id_seq', 1, false);


--
-- TOC entry 1783 (class 0 OID 26039)
-- Dependencies: 1509
-- Data for Name: tags; Type: TABLE DATA; Schema: public; Owner: da01
--

INSERT INTO tags (id, filename) VALUES (167, 'stuff_for_dudes');
INSERT INTO tags (id, filename) VALUES (168, 'stuff_for_dudettes');
INSERT INTO tags (id, filename) VALUES (169, 'stuff_for_pets');
INSERT INTO tags (id, filename) VALUES (170, 'stuff_for_mommies_and_dads');
INSERT INTO tags (id, filename) VALUES (171, 'edible_delicious');
INSERT INTO tags (id, filename) VALUES (172, 'books_articles');
INSERT INTO tags (id, filename) VALUES (173, 'techie_wonders');
INSERT INTO tags (id, filename) VALUES (174, 'miscellaneous');
INSERT INTO tags (id, filename) VALUES (175, 'art_design');


-- Completed on 2009-08-26 01:15:43 EDT

--
-- PostgreSQL database dump complete
--

