### 1) The build should trigger as soon as anyone in the dev team checks in code to master branch.

         >> Edit your Build Defination.
         >> Click on te Triggers Tab.
         >> Select Enable continuous integration.
      
### 2) There will be test projects which will create and maintained in the solution along the Web and API. The trigger should build all the 3 projects - Web, API and test.The build should not be successful if any test fails.
       
        >> Create Build Defination and Select Enable continuous integration option in triggers.
        >> The above step would run the build defination if any changes are made to the main/master branch.
                  >>>> For a granular control, you can use Path Filter alongwith Branch Filter
        >> In the Publish Test Results task in the Build Defination, select "Fail if there are test failures" to take care of failing the build if any test case gets failed.
        
### 3) The deployment of code and artifacts should be automated to Dev environment.
        
        >> Create a Realease pipeline and pass the build pipeline that publishes the artifact.
        >> Create multiple stages as per environment Dev, QA and Prod
        >> For Dev Stage, enable Continuous deployment trigger, which would create a release every time a new build is available.
        
### 4) Upon successful deployment to the Dev environment, deployment should be easily promoted to QA and Prod through automated process.

        >> In the QA and Prod Stages, under Triggers in the Pre-Deployment Conditions, select "After Stage" 

### 5) The deployments to QA and Prod should be enabled with Approvals from approvers only.

        >> In the QA and Prod Stages, enable "Pre-deployment approvals" in the Pre-Deployment Conditions and pass the Approvers.
