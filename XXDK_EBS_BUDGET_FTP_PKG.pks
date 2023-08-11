CREATE OR REPLACE PACKAGE APPS.xxdk_ebs_budget_ftp_pkg
AS
   -- --------------------------------------------------------------------------
   -- Name         : APPS.xxdk_ebs_budget_ftp_pkg
   -- Author       : Shreyas
   -- Description  : Basic FTP API. For usage notes see:
   -- Ammedments   :
   --   When         Who       What
   --   ===========  ========  =================================================
   --   03-July-2023  Shreyas Initial Creation



   PROCEDURE main_proc (errbuf             OUT VARCHAR2,
                        retcode            OUT VARCHAR2,
                        P_po_num_from IN VARCHAR2
                       );
END xxdk_ebs_budget_ftp_pkg;
/
