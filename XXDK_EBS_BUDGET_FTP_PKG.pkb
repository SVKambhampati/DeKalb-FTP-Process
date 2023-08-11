/* Formatted on 8/10/2023 11:44:00 PM (QP5 v5.396) */
CREATE OR REPLACE PACKAGE BODY APPS.xxdk_ebs_budget_ftp_pkg
AS
    -- --------------------------------------------------------------------------
    -- Name         : APPS.xxdk_hubspab_ftp_pkg
    -- Author       : Shreyas
    -- Description  : Basic FTP API. For usage notes see:
    -- Ammedments   :
    --   When         Who       What
    --   ===========  ========  =================================================
    --   03-Aug-2023  Shreyas Initial Creation

    l_responsibility_id     NUMBER;
    l_resp_application_id   NUMBER;
    l_security_group_id     NUMBER;
    l_user_id               NUMBER;
    l_request_id            NUMBER;
    l_conn                  UTL_TCP.connection;
    P_FTP_SERVER            VARCHAR2 (50);
    P_FTP_PORT              VARCHAR2 (50);
    P_FTP_USER              VARCHAR2 (50);
    P_FTP_PWD               VARCHAR2 (50);
    P_HUBSPAN_SERVER        VARCHAR2 (50);
    P_HUBSPAN_USER          VARCHAR2 (50);
    P_HUBSPAN_PWD           VARCHAR2 (50);
    P_HUBSPAN_PORT          VARCHAR2 (50);
    P_FTP_FOLDER            VARCHAR2 (50);
    P_HUB_FOLDER            VARCHAR2 (50);

    PROCEDURE main_proc (errbuf             OUT VARCHAR2,
                         retcode            OUT VARCHAR2,
                         P_po_num_from   IN     VARCHAR2)
    AS
        CURSOR c_request_id IS
            SELECT DISTINCT fcr.request_id
              FROM apps.fnd_concurrent_programs_vl  fcp,
                   apps.fnd_concurrent_requests     fcr
             WHERE     fcr.concurrent_program_id = fcp.concurrent_program_id
                   AND TRUNC (fcr.last_update_date) = TRUNC (SYSDATE)
                   AND TRUNC (
                             MOD (
                                 MOD (SYSDATE - fcr.last_update_date, 1) * 24,
                                 1)
                           * 60) <
                       59
                   AND TRUNC (24 * MOD (SYSDATE - fcr.last_update_date, 1)) <
                       1
                   AND fcp.user_concurrent_program_name LIKE
                           'DeKalb EBS Nightly Budget Data to PBCS%';
    BEGIN
        DBMS_OUTPUT.put_line ('starting ');

        fnd_file.put_line (FND_FILE.LOG, 'starting ');


        SELECT user_id,
               responsibility_id,
               responsibility_application_id,
               security_group_id
          INTO l_user_id,
               l_responsibility_id,
               l_resp_application_id,
               l_security_group_id
          FROM fnd_user_resp_groups
         WHERE     user_id = (SELECT user_id
                                FROM fnd_user
                               WHERE user_id = 8649)
               AND responsibility_id =
                   (SELECT responsibility_id
                      FROM fnd_responsibility_vl
                     WHERE responsibility_name = 'System Administrator');


        --
        --To set environment context.
        --
        apps.fnd_global.apps_initialize (l_user_id,
                                         l_responsibility_id,
                                         l_resp_application_id);

        --
        --Submitting Concurrent Request
        --

        --
        --Submitting Concurrent Request
        --
        fnd_file.put_line (FND_FILE.LOG, 'Submitting Concurrent Request ');



        --
        IF l_request_id = 0
        THEN
            DBMS_OUTPUT.put_line ('Concurrent request failed to submit');
        ELSE
            DBMS_OUTPUT.put_line (
                   'Successfully Submitted the Concurrent Request: '
                || l_request_id);
        END IF;

        /* make sure to complete the concurrent job*/

        IF P_po_num_from IS NULL
        THEN
            FOR r_request_id IN c_request_id
            LOOP
                fnd_file.put_line (
                    FND_FILE.LOG,
                    'Test here loop ' || r_request_id.request_id);

                /**/
                l_request_id :=
                    fnd_request.submit_request (
                        application   => 'XXDK',     -- Application Short Name
                        program       => 'XXDK_JOB_FTP_UNIX', -- Program Short Name
                        description   => 'XXDK_JOB_FTP_UNIX', -- Any Meaningful Description
                        start_time    => SYSDATE,                -- Start Time
                        sub_request   => FALSE,    -- Subrequest Default False
                        argument1     => r_request_id.request_id -- Parameters Starting
                                                                );
                --
                COMMIT;
            END LOOP;
        ELSE
            /*  */
            fnd_file.put_line (FND_FILE.LOG, ' ELSE block ');

            l_request_id :=
                fnd_request.submit_request (
                    application   => 'XXDK',         -- Application Short Name
                    program       => 'XXDK_JOB_FTP_UNIX', -- Program Short Name
                    description   => 'XXDK_JOB_FTP_UNIX', -- Any Meaningful Description
                    start_time    => SYSDATE,                    -- Start Time
                    sub_request   => FALSE,        -- Subrequest Default False
                    argument1     => P_po_num_from      -- Parameters Starting
                                                  );
            --
            COMMIT;
        -- l_conn := xxdk_ftp_util.login('ITR12TSTAP2', '21', 'appluat', 'appluat1');
        /*
        l_conn :=
              xxdk_ftp_util.login (P_FTP_SERVER,
                                   P_FTP_PORT,
                                   P_FTP_USER,
                                   P_FTP_PWD);
           xxdk_ftp_util.ASCII (p_conn => l_conn);
              fnd_file.put_line(FND_FILE.LOG,' ELSE block '|| P_FTP_FOLDER);

           xxdk_ftp_util.get (
              p_conn        => l_conn,
              p_from_file   => P_FTP_FOLDER || 'o' || P_po_num_from|| '.out',
              p_to_dir      => 'MY_DOCS',
              p_to_file     => 'hubspan_' || P_po_num_from || '.xml');
            xxdk_ftp_util.LOGOUT (l_conn);
            fnd_file.put_line(FND_FILE.LOG,'hubspan_' || P_po_num_from || '.xml');
            fnd_file.put_line(FND_FILE.LOG,' hubspan_ '|| P_po_num_from);

           l_conn :=
              xxdk_ftp_util.login (P_HUBSPAN_SERVER,
                                   P_HUBSPAN_PORT,
                                   P_HUBSPAN_USER,
                                   P_HUBSPAN_PWD);
           xxdk_ftp_util.ASCII (p_conn => l_conn);
           xxdk_ftp_util.put (
              p_conn        => l_conn,
              p_from_dir    => 'MY_DOCS',
              p_from_file   => 'hubspan_' || P_po_num_from || '.xml',
              p_to_file     => P_HUB_FOLDER || 'hubspan_' || P_po_num_from || '.xml');
           fnd_file.put_line(FND_FILE.LOG,P_HUB_FOLDER || 'hubspan_' || P_po_num_from || '.xml');

           xxdk_ftp_util.LOGOUT (l_conn);   */

        END IF;

        fnd_file.put_line (FND_FILE.LOG, 'xxdk_hubspan_ftp_pkg ');
    --
    EXCEPTION
        WHEN OTHERS
        THEN
            DBMS_OUTPUT.put_line (
                   'Error While Submitting Concurrent Request '
                || TO_CHAR (SQLCODE)
                || '-'
                || SQLERRM);
            fnd_file.put_line (FND_FILE.LOG, TO_CHAR (SQLCODE));
            fnd_file.put_line (FND_FILE.LOG, SQLERRM);
    END;
END xxdk_ebs_budget_ftp_pkg;
/
