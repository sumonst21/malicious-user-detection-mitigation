# F5 Distributed Cloud Platform malicious user detection and mitigation
***


**Table of Contents:** <br />
---
&nbsp;&nbsp;&nbsp;&nbsp;•	**[Overview](#overview)** <br />
&nbsp;&nbsp;&nbsp;&nbsp;•	**[Scenarios](#scenarios)** <br />
&nbsp;&nbsp;&nbsp;&nbsp;•	**[Flow Chart](#flow-chart)** <br />
&nbsp;&nbsp;&nbsp;&nbsp;•       **[Steps to import the repository](#steps-to-import-the-repository)**<br />
&nbsp;&nbsp;&nbsp;&nbsp;•	**[Pre-requisites](#pre-requisites)** <br />
&nbsp;&nbsp;&nbsp;&nbsp;•	**[Steps to run the workflow](#steps-to-run-the-workflow)** <br />


**Overview:**<br />
---
F5 Distributed Cloud Web Application and API Protection (F5 XC WAAP) offers an AI/ML-based solution for monitoring malicious user events and mitigating them automatically safeguarding applications against potential threats. For more information, please have a look at these articles:<br /><br />
[AI/ML detection of Malicious Users using F5 Distributed Cloud WAAP – Part I](https://community.f5.com/t5/technical-articles/ai-ml-detection-of-malicious-users-using-f5-distributed-cloud/ta-p/295052)<br />
[AI/ML detection of Malicious Users using F5 Distributed Cloud WAAP – Part II](https://community.f5.com/t5/technical-articles/ai-ml-detection-of-malicious-users-using-f5-distributed-cloud/ta-p/296517)<br />
[AI/ML detection of Malicious Users using F5 Distributed Cloud WAAP – Part III](https://community.f5.com/t5/technical-articles/ai-ml-detection-of-malicious-users-using-f5-distributed-cloud/ta-p/299014)<br /><br />
This repository consists of two workflows covering demo scenarios for malicious user detection and mitigation using F5 XC WAAP:<br />
1.	Single LB malicious user detection and default mitigation of high-risk IPs <br />
2.	Multi LB malicious user detection and custom mitigation of WAF security events <br />


**Scenarios:**<br />
---
**Single LB malicious user detection and default mitigation of high-risk IPs:**<br />
In this scenario we are bringing up a http lb and configure it to detect and mitigate malicious user events using default mitigation rule. In second part of this demo, we will generate tor requests and fetch the logs from XC console to validate the detection and mitigation action <br /><br />
**Multi LB malicious user detection and custom mitigation of WAF security events:**<br />
In this scenario we are bringing up a https lb with an app type enabling detection, app firewall in blocking mode and custom malicious user mitigation policy. In the second part of this scenario we are generating XSS attack and validate the logs fetched from XC console. <br />


**Flow Chart:**<br />
---
![2](https://user-images.githubusercontent.com/90624610/199253218-5addf00c-7001-412e-8191-db6a634d813d.JPG)
<br />
<br />

![3](https://user-images.githubusercontent.com/90624610/199255655-3b3715bc-06ce-4cb7-b7af-9cbc5f80d676.JPG)
<br />


**Steps to import the repository:**<br />
---
![t1](https://user-images.githubusercontent.com/90624610/204997112-2dbbad4d-ff2e-4e55-98f7-9e4b1f6e990a.JPG)
<br /><br />
![t2](https://user-images.githubusercontent.com/90624610/204997141-0a166247-a24c-4326-994c-4d43456160c1.JPG)
<br /><br />
![t3](https://user-images.githubusercontent.com/90624610/204997162-81dcf88d-7dec-47fc-9e19-8d1e471628c4.JPG)
<br /><br />
![t4](https://user-images.githubusercontent.com/90624610/204997187-8d6ba77d-5e35-4ab9-b79c-2db6c0693b3d.JPG)
<br />


**Pre-requisites:**<br />
---
1.	Login to F5 XC console and create an `API Certificate` and `API Token`. Please refer this page for the API Certificate and API Token generation: [https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials](https://docs.cloud.f5.com/docs/how-to/user-mgmt/credentials) <br />
2.	Move the `API Certificate p12` file to the repository's root directory and update the p12 file name in `user_inputs.json` file <br />
3.	Update the `API Token` in `user_inputs.json` file
3.	Create a namespace in XC console, navigate to: `Home->Administration->Personal Management->My Namespaces->Add Namespace` or use `default` namespace and update the namespace name in the `user_inputs.json` file<br />
4.	Make sure to add delegated domain in XC console and update the domain as well as tenant API url in `user_inputs.json` file. Please follow the steps for domain delegation mentioned in doc: [https://docs.cloud.f5.com/docs/how-to/app-networking/domain-delegation](https://docs.cloud.f5.com/docs/how-to/app-networking/domain-delegation) <br />
6.	Host an application to a server and update the public IP and port of the application server in `user_inputs.json` file <br />
	`Note:` Make sure to double check the IP and port before adding it to `user_inputs.json` file as workflow will fail if incorrect entries are updated.

```
Example:

< > -> changes needed in user_inputs.json file

{
	"api_p12_file": "../<api-creds.p12>",
	"p12_file_pass": "<password used while creating API Certificate p12 file>",
	"api_token": "<API token created in Step-1>",
        "api_url": "https://<your-tenant-name>.console.ves.volterra.io/api",
        "namespace": "<custom namespace or default>",
        "domain": "<delegated-domain>",
        "originip": "<Public IP of hosted application>",
        "originport": "<Port of hosted application>"	
}

```


**Steps to run the workflow:**<br />
---
&nbsp;&nbsp;&nbsp;&nbsp;•	Navigate to `Actions` tab in the repository and select the workflow you want to execute <br />
&nbsp;&nbsp;&nbsp;&nbsp;•	Click on `Run workflow` on the right side of the UI <br /><br />

**Steps:**<br />

![16](https://user-images.githubusercontent.com/90624610/204998797-77022c51-59d1-4516-bb28-1b6e97d84834.JPG)
<br />

**Jobs in the workflows:**<br />

![19](https://user-images.githubusercontent.com/90624610/199423027-c7964d80-89b8-49e9-9a80-6c06d2fab84f.JPG)
<br />

**Fetched XC logs in test job:**<br />

![17](https://user-images.githubusercontent.com/90624610/199406640-93ce319e-fbb2-4973-9b5a-94e5cf91eee7.JPG)
