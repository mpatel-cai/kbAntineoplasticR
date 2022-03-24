run_setup <-
  function (conn,
            conn_fun = "pg13::local_connect(verbose = {verbose})",
            omop_vocabulary_schema = "omop_vocabulary",
            path_to_csvs,
            verbose = TRUE,
            render_sql = TRUE,
            render_only = FALSE,
            checks = "") {

    if (missing(conn)) {
      conn <- eval(rlang::parse_expr(glue::glue(conn_fun)))
      on.exit(pg13::dc(conn = conn, verbose = verbose), add = TRUE,
              after = TRUE)
    }

    omop_release_version <-
      pg13::query(
        conn = conn,
        sql_statement = "SELECT sa_release_version FROM public.setup_athena_log WHERE sa_datetime IN (SELECT MAX(sa_datetime) FROM public.setup_athena_log);",
        verbose = verbose, render_sql = render_sql, render_only = render_only,
        checks = checks) %>% unlist() %>% unname()

    monohierarchy_drug_csv <-
      system.file(package = "kbAntineoplasticR",
                  "kb_antineoplastic",
                  "curated_content",
                  "mh_drug.csv")

    condition_map_csv <-
      system.file(package = "kbAntineoplasticR",
                  "kb_antineoplastic",
                  "curated_content",
                  "cond_pt360_icd10_map.csv")


    # HemOnc OMOP Vocabulary Subset
    sql_statement <-
    glue::glue(
    paste(
    readLines(
      system.file(package = "kbAntineoplasticR",
                  "sql",
                  "load.sql")
    ),
    collapse = "\n"
    )
    )

    pg13::send(
      conn = conn,
      sql_statement = sql_statement,
      checks = checks,
      verbose = verbose,
      render_sql = render_sql,
      render_only = render_only
    )

    ## Log





  }
