CREATE SCHEMA IF NOT EXISTS kb_antineoplastic;

DROP TABLE IF EXISTS kb_antineoplastic.hemonc_concept;
CREATE TABLE IF NOT EXISTS kb_antineoplastic.hemonc_concept (
   concept_id        	int 			NOT NULL,
   concept_code      	varchar(10) 	NOT NULL,
   concept_name      	varchar(2000) 	NOT NULL,
   concept_class_id  	varchar(20) 	NOT NULL
);
TRUNCATE kb_antineoplastic.hemonc_concept;
INSERT INTO kb_antineoplastic.hemonc_concept
	select
	    concept_id,
	    concept_code,
	    concept_name,
	    concept_class_id
      		from {omop_vocabulary_schema}.concept
      		where vocabulary_id = 'HemOnc'
;

CREATE TABLE IF NOT EXISTS kb_antineoplastic.hemonc_concept_ancestor (
   ancestor_concept_id       int 			NOT NULL,
   ancestor_concept_code     varchar(10) 	NOT NULL,
   descendant_concept_id     int 			NOT NULL,
   descendant_concept_code   varchar(10) 	NOT NULL,
   min_levels_of_separation  int NOT 		NULL,
   max_levels_of_separation  int NOT 		NULL
);
TRUNCATE kb_antineoplastic.hemonc_concept_ancestor;
INSERT INTO kb_antineoplastic.hemonc_concept_ancestor
	select
	    ancestor_concept_id,
	    c1.concept_code as ancestor_concept_code,
	    descendant_concept_id,
	    c2.concept_code as descendant_concept_code,
	    min_levels_of_separation,
	    max_levels_of_separation
	      from {omop_vocabulary_schema}.concept_ancestor ca
	      	inner join (select * from {omop_vocabulary_schema}.concept where vocabulary_id = 'HemOnc') c1
	        	on ca.ancestor_concept_id = c1.concept_id
	      	inner join (select * from {omop_vocabulary_schema}.concept where vocabulary_id = 'HemOnc') c2
	       		 on ca.descendant_concept_id = c2.concept_id
;

CREATE TABLE IF NOT EXISTS kb_antineoplastic.hemonc_concept_relationship (
   concept_id_1      	int  			NOT NULL,
   concept_code_1    	varchar(20) 	NOT NULL,
   relationship_id   	varchar(50) 	NOT NULL,
   concept_id_2      	int 			NOT NULL,
   concept_code_2    	varchar(20) 	NOT NULL
);
TRUNCATE kb_antineoplastic.hemonc_concept_relationship;
INSERT INTO kb_antineoplastic.hemonc_concept_relationship
 	select
	    rel.concept_id_1,
	    c1.concept_code as concept_code_1,
	    relationship_id,
	    rel.concept_id_2,
	    c2.concept_code as concept_code_2
	      from {omop_vocabulary_schema}.concept_relationship rel
	        inner join (select * from {omop_vocabulary_schema}.concept where vocabulary_id ='HemOnc') c1
	          on rel.concept_id_1 = c1.concept_id
	        inner join (select * from {omop_vocabulary_schema}.concept where vocabulary_id = 'HemOnc') c2
	          on rel.concept_id_2 = c2.concept_id
;

CREATE TABLE IF NOT EXISTS kb_antineoplastic.monohierarchy_drug (
	drug_code 			varchar(20)  	NOT NULL,
	drug_name 			varchar(200) 	NOT NULL,
	antineoplastic  	varchar(20),
	broad_category 		varchar(200),
	general_category 	varchar(200),
	specific_category 	varchar(200)
);
TRUNCATE kb_antineoplastic.monohierarchy_drug;
COPY kb_antineoplastic.monohierarchy_drug FROM '{monohierarchy_drug_csv}' CSV HEADER;

CREATE TABLE IF NOT EXISTS kb_antineoplastic.condition_map (
    condition_code    	varchar(20) 	NOT NULL,
    condition_name    	varchar(200) 	NOT NULL,
    pt360_condition   	varchar(50),
    icd10_code        	text
);
TRUNCATE kb_antineoplastic.condition_map;
COPY kb_antineoplastic.condition_map FROM '{condition_map_csv}' CSV HEADER;

