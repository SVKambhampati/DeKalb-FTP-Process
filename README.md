# DeKalb-FTP-Process
Building FTP Process for DeKalb EBS Nightly Budget Data to PBCS

In collaboration with DeKalb County Government, this internship project focused on enhancing their data management efficiency. The primary goal was to establish an FTP process for transferring nightly budget data from DeKalb's E-Business Suite (EBS) to Oracle Planning and Budgeting Cloud Service (PBCS).

Key Achievements:

Oracle Concurrent Jobs Developed:
DeKalb Job FTP Process: An automated process was developed, which can be executed either by providing a specific request ID or by default, using the previously run request. This flexibility enhances the convenience of managing data transfers.
DeKalb Job FTP Unix Process: A Unix-based process was designed to complement the FTP process, ensuring seamless integration and efficient data flow.
Code Build Details:

Soure Code 
XXDK_EBS_BUDGET_FTP_PKG: This component encapsulates the logic necessary for extracting and formatting budget data from DeKalb's EBS, preparing it for the FTP transfer to PBCS. The package is a critical building block in the data synchronization process.
XXCUST_JOB_FTP_SH.prog: Located at $XXDK_TOP/bin, this program plays a pivotal role in orchestrating the entire FTP process. It coordinates the execution of various components, ensuring a smooth and reliable data transfer.
