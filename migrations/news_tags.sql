--
-- PostgreSQL database dump
--

-- Started on 2009-09-07 11:43:57 EDT

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- TOC entry 1785 (class 0 OID 0)
-- Dependencies: 1503
-- Name: news_tags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: da01
--

SELECT pg_catalog.setval('news_tags_id_seq', 177, false);


--
-- TOC entry 1782 (class 0 OID 37039)
-- Dependencies: 1504
-- Data for Name: news_tags; Type: TABLE DATA; Schema: public; Owner: da01
--

COPY news_tags (id, filename) FROM stdin;
167	stuff_for_dudes
168	stuff_for_dudettes
169	stuff_for_pets
170	stuff_for_mommies_and_dads
171	edible_delicious
172	books_articles
173	techie_wonders
174	miscellaneous
175	art_design
176	surfer_hearts
\.


-- Completed on 2009-09-07 11:43:58 EDT

--
-- PostgreSQL database dump complete
--

