public class StudyTemplateCreation {
    public static void createTemplate() {
        Study_Template__c st = new Study_Template__c();
        st.Study_template_Name__c = 'Study Template 1';
        insert st;
        
        List<Study_Template_Milestone__c> studyTemplateMilestone = new List<Study_Template_Milestone__c>();
        
        Study_Template_Milestone__c stm1 = new Study_Template_Milestone__c();
        stm1.Display_Name__c = 'Slot Requested';
        stm1.Study_Template__c = st.Id;
        stm1.Order__c = 1;
        stm1.COI_Generation__c = false;
        stm1.Site_Facing__c = true;
        stm1.Sponsor_facing__c = true;
        stm1.Read_Access_Queues__c = 'Logistics Co-ordinator;Manufacturing Scheduler';
        stm1.Write_Access_Queue__c = 'Clinical Site';
        studyTemplateMilestone.add(stm1);
        
        Study_Template_Milestone__c stm2 = new Study_Template_Milestone__c();
        stm2.Display_Name__c = 'Slot Reserved';
        stm2.Study_Template__c = st.Id;
        stm2.Order__c = 2;
        stm2.COI_Generation__c = false;
        stm2.Site_Facing__c = true;
        stm2.Sponsor_facing__c = true;
        stm2.Read_Access_Queues__c = 'Clinical Site;Logistics Co-ordinator';
        stm2.Write_Access_Queue__c = 'Manufacturing Scheduler';
        studyTemplateMilestone.add(stm2);
        
        Study_Template_Milestone__c stm3 = new Study_Template_Milestone__c();
        stm3.Display_Name__c = 'Subject ID Completed';
        stm3.Study_Template__c = st.Id;
        stm3.Order__c = 3;
        stm3.COI_Generation__c = true;
        stm3.Site_Facing__c = true;
        stm3.Sponsor_facing__c = true;
        stm3.Read_Access_Queues__c = 'Logistics Co-ordinator';
        stm3.Write_Access_Queue__c = 'Clinical Site';
        studyTemplateMilestone.add(stm3);
        
        Study_Template_Milestone__c stm4 = new Study_Template_Milestone__c();
        stm4.Display_Name__c = 'Slot Booked';
        stm4.Study_Template__c = st.Id;
        stm4.Order__c = 4;
        stm4.COI_Generation__c = false;
        stm4.Site_Facing__c = true;
        stm4.Sponsor_facing__c = true;
        stm4.Read_Access_Queues__c = 'Manufacturing Scheduler';
        stm4.Write_Access_Queue__c = 'Logistics Co-ordinator';
        studyTemplateMilestone.add(stm4);
        
        Study_Template_Milestone__c stm5 = new Study_Template_Milestone__c();
        stm5.Display_Name__c = 'Apheresis Completed';
        stm5.Study_Template__c = st.Id;
        stm5.Order__c = 5;
        stm5.COI_Generation__c = false;
        stm5.Site_Facing__c = true;
        stm5.Sponsor_facing__c = true;
        stm5.Read_Access_Queues__c = '';
        stm5.Write_Access_Queue__c = 'Clinical Site;Logistics Co-ordinator';
        studyTemplateMilestone.add(stm5);
        
        Study_Template_Milestone__c stm6 = new Study_Template_Milestone__c();
        stm6.Display_Name__c = 'Apheresis Handed Off to Courier';
        stm6.Study_Template__c = st.Id;
        stm6.Order__c = 6;
        stm6.COI_Generation__c = false;
        stm6.Site_Facing__c = true;
        stm6.Sponsor_facing__c = true;
        stm6.Read_Access_Queues__c = 'Logistics Co-ordinator';
        stm6.Write_Access_Queue__c = 'Clinical Site';
        studyTemplateMilestone.add(stm6);
        
        Study_Template_Milestone__c stm7 = new Study_Template_Milestone__c();
        stm7.Display_Name__c = 'Manufacturing Started';
        stm7.Study_Template__c = st.Id;
        stm7.Order__c = 7;
        stm7.COI_Generation__c = false;
        stm7.Site_Facing__c = true;
        stm7.Sponsor_facing__c = true;
        stm7.Read_Access_Queues__c = 'Logistics Co-ordinator;Manufacturing Scheduler;Clinical Site;Warehouse Operator';
        stm7.Write_Access_Queue__c = '';
        studyTemplateMilestone.add(stm7);
        
        Study_Template_Milestone__c stm8 = new Study_Template_Milestone__c();
        stm8.Display_Name__c = 'Manufacturing Completed';
        stm8.Study_Template__c = st.Id;
        stm8.Order__c = 8;
        stm8.COI_Generation__c = false;
        stm8.Site_Facing__c = true;
        stm8.Sponsor_facing__c = true;
        stm8.Read_Access_Queues__c = 'Manufacturing Scheduler;Clinical Site;Warehouse Operator;QA';
        stm8.Write_Access_Queue__c = 'Logistics Co-ordinator';
        studyTemplateMilestone.add(stm8);
        
        Study_Template_Milestone__c stm9 = new Study_Template_Milestone__c();
        stm9.Display_Name__c = 'Quality Released';
        stm9.Study_Template__c = st.Id;
        stm9.Order__c = 9;
        stm9.COI_Generation__c = false;
        stm9.Site_Facing__c = true;
        stm9.Sponsor_facing__c = true;
        stm9.Read_Access_Queues__c = 'Logistics Co-ordinator;Manufacturing Scheduler;Clinical Site;Warehouse Operator';
        stm9.Write_Access_Queue__c = 'QA';
        studyTemplateMilestone.add(stm9);
        
        Study_Template_Milestone__c stm10 = new Study_Template_Milestone__c();
        stm10.Display_Name__c = 'IP Pack-Out Completed';
        stm10.Study_Template__c = st.Id;
        stm10.Order__c = 10;
        stm10.COI_Generation__c = false;
        stm10.Site_Facing__c = false;
        stm10.Sponsor_facing__c = true;
        stm10.Read_Access_Queues__c = 'Logistics Co-ordinator;Manufacturing Scheduler;Clinical Site';
        stm10.Write_Access_Queue__c = 'Warehouse Operator';
        studyTemplateMilestone.add(stm10);
        
        Study_Template_Milestone__c stm11 = new Study_Template_Milestone__c();
        stm11.Display_Name__c = 'IP Handed Off to Courier';
        stm11.Study_Template__c = st.Id;
        stm11.Order__c = 11;
        stm11.COI_Generation__c = false;
        stm11.Site_Facing__c = true;
        stm11.Sponsor_facing__c = true;
        stm11.Read_Access_Queues__c = 'Logistics Co-ordinator;Manufacturing Scheduler;Clinical Site';
        stm11.Write_Access_Queue__c = 'Warehouse Operator';
        studyTemplateMilestone.add(stm11);
        
        Study_Template_Milestone__c stm12 = new Study_Template_Milestone__c();
        stm12.Display_Name__c = 'IP Received';
        stm12.Study_Template__c = st.Id;
        stm12.Order__c = 12;
        stm12.COI_Generation__c = false;
        stm12.Site_Facing__c = true;
        stm12.Sponsor_facing__c = true;
        stm12.Read_Access_Queues__c = '';
        stm12.Write_Access_Queue__c = 'Logistics Co-ordinator;Clinical Site';
        studyTemplateMilestone.add(stm12);
        
        Study_Template_Milestone__c stm13 = new Study_Template_Milestone__c();
        stm13.Display_Name__c = 'IP Infusion Completed';
        stm13.Study_Template__c = st.Id;
        stm13.Order__c = 13;
        stm13.COI_Generation__c = false;
        stm13.Site_Facing__c = true;
        stm13.Sponsor_facing__c = true;
        stm13.Read_Access_Queues__c = 'Logistics Co-ordinator';
        stm13.Write_Access_Queue__c = 'Clinical Site';
        studyTemplateMilestone.add(stm13);
        
        Study_Template_Milestone__c stm14 = new Study_Template_Milestone__c();
        stm14.Display_Name__c = 'IP Reconciliation Completed';
        stm14.Study_Template__c = st.Id;
        stm14.Order__c = 14;
        stm14.COI_Generation__c = false;
        stm14.Site_Facing__c = false;
        stm14.Sponsor_facing__c = true;
        stm14.Read_Access_Queues__c = 'Logistics Co-ordinator';
        stm14.Write_Access_Queue__c = 'Clinical Site';
        studyTemplateMilestone.add(stm14);
        
        insert studyTemplateMilestone;
        
        List<Study_Template_Milestone_Task__c> studyTemplateMilestoneTask = new List<Study_Template_Milestone_Task__c>();
        
        Study_Template_Milestone_Task__c task1 =
            new Study_Template_Milestone_Task__c(
                Apheresis_Shipment__c = false,
                Display_Name__c = 'Slot Request',
                Order__c = 1,
                Drug_Product_Shipment__c = false,
                Read_Access_Queues__c = 'Logistics Co-ordinator;Manufacturing Scheduler',
                Site_Facing__c = true,
                Sponsor_facing__c = true,
                Study_Template_Milestone__c = studyTemplateMilestone[0].Id,
                Task_Owner__c = 'Clinical Site User Queue',
                Verify__c = false,
                Write_Access_Queues__c = 'Clinical Site' );
        studyTemplateMilestoneTask.add(task1);
        
        Study_Template_Milestone_Task__c task2 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Slot Reserved', Order__c = 1,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Clinical Site;Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = true, 
                                                 Study_Template_Milestone__c = studyTemplateMilestone[1].Id,
                                                 Task_Owner__c = '', Verify__c = false,
                                                 Write_Access_Queues__c = 'Manufacturing Scheduler');
        studyTemplateMilestoneTask.add(task2);
        
        Study_Template_Milestone_Task__c task3 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Upload ICF', Order__c = 1,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[2].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = true,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task3);
        
        Study_Template_Milestone_Task__c task4 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Update Subject ID', Order__c = 2,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[2].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = true,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task4);
        
        Study_Template_Milestone_Task__c task5 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Confirm SID, ICF and Eligibility', Order__c = 3,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Clinical Site', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[2].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = true,
                                                 Write_Access_Queues__c = 'Logistics Co-ordinator');
        studyTemplateMilestoneTask.add(task5);
        
        Study_Template_Milestone_Task__c task6 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Slot Booked', Order__c = 1,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Manufacturing Scheduler', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[3].Id,
                                                 Task_Owner__c = 'Logistic Coordinator Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Logistics Co-ordinator');
        studyTemplateMilestoneTask.add(task6);
        
        Study_Template_Milestone_Task__c task7 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = true,
                                                 Display_Name__c = 'Apheresis Shipment', Order__c = 1,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator;Manufacturing Scheduler', Site_Facing__c = false,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[4].Id,
                                                 Task_Owner__c = 'Logistic Coordinator Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Logistics Co-ordinator');
        studyTemplateMilestoneTask.add(task7);
        
        Study_Template_Milestone_Task__c task8 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Apheresis Collection',
                                                 Order__c = 2, Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = false,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[4].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Clinical site');
        studyTemplateMilestoneTask.add(task8);
        
        Study_Template_Milestone_Task__c task9 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Apheresis Collection Information', Order__c = 3,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = false,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[4].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = true,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task9);
        
        Study_Template_Milestone_Task__c task10 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Comfirm Patient Identifier', Order__c = 4,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = false,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[4].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task10);
        
        Study_Template_Milestone_Task__c task11 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Print AWB', Order__c = 5,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = false,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[4].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task11);
        
        Study_Template_Milestone_Task__c task12 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Template Serial Number', Order__c = 6,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[4].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = true,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task12);
        
        Study_Template_Milestone_Task__c task13 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Acknowledge Apheresis Handover to Courier',
                                                 Order__c = 1, Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[5].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task13);
        
        Study_Template_Milestone_Task__c task14 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Manufacturing Start', Order__c = 1,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Clinical Site;Logistics Co-ordinator;Manufacturing Scheduler', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[6].Id,
                                                 Task_Owner__c = 'Logistic Coordinator Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Logistics Co-ordinator');
        studyTemplateMilestoneTask.add(task14);
        
        Study_Template_Milestone_Task__c task15 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Manufacturing Details', Order__c = 1,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Clinical Site;Manufacturing Scheduler;QA', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[7].Id,
                                                 Task_Owner__c = 'Logistic Coordinator Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Logistics Co-ordinator');
        studyTemplateMilestoneTask.add(task15);
        
        Study_Template_Milestone_Task__c task16 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Courier',
                                                 Order__c = 2, Drug_Product_Shipment__c = true,
                                                 Read_Access_Queues__c = 'Warehouse Operator;Manufacturing Scheduler;QA', Site_Facing__c = false,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[7].Id,
                                                 Task_Owner__c = 'Logistic Coordinator Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Logistics Co-ordinator');
        studyTemplateMilestoneTask.add(task16);
        
        Study_Template_Milestone_Task__c task17 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Quality Release', Order__c = 1,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator;Manufacturing Scheduler;Warehouse Operator;Clinical Site', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[8].Id,
                                                 Task_Owner__c = '', Verify__c = false,
                                                 Write_Access_Queues__c = 'QA');
        studyTemplateMilestoneTask.add(task17);
        
        Study_Template_Milestone_Task__c task18 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Schedule IP Packout', Order__c = 1,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Clinical Site;Logistics Co-ordinator;Manufacturing Scheduler', Site_Facing__c = false,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[9].Id,
                                                 Task_Owner__c = '', Verify__c = false,
                                                 Write_Access_Queues__c = 'Warehouse Operator');
        studyTemplateMilestoneTask.add(task18);
        
        Study_Template_Milestone_Task__c task19 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'IP Pack-out',
                                                 Order__c = 2, Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Clinical Site;Logistics Co-ordinator;Manufacturing Scheduler', Site_Facing__c = false,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[9].Id,
                                                 Task_Owner__c = '', Verify__c = true,
                                                 Write_Access_Queues__c = 'Warehouse Operator');
        studyTemplateMilestoneTask.add(task19);
        
        Study_Template_Milestone_Task__c task20 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Acknowledge IP Handed Over To Courier', Order__c = 1,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Clinical Site;Logistics Co-ordinator;Manufacturing Scheduler', Site_Facing__c = false,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[10].Id,
                                                 Task_Owner__c = '', Verify__c = false,
                                                 Write_Access_Queues__c = 'Warehouse Operator');
        studyTemplateMilestoneTask.add(task20);
        
        Study_Template_Milestone_Task__c task21 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Monitor Shipment Temperature', Order__c = 1,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = false,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[11].Id,
                                                 Task_Owner__c = '', Verify__c = false,
                                                 Write_Access_Queues__c = 'Logistics Co-ordinator');
        studyTemplateMilestoneTask.add(task21);
        
        Study_Template_Milestone_Task__c task22 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'IP Receipt Storage',
                                                 Order__c = 2, Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = false,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[11].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task22);
        
        Study_Template_Milestone_Task__c task23 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Open LN2 Dewar and Unpack the IP', Order__c = 3,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[11].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Clinical Site;');
        studyTemplateMilestoneTask.add(task23);
        
        Study_Template_Milestone_Task__c task24 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Bag Entry', Order__c = 4,
                                                 Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[11].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = true,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task24);
        
        Study_Template_Milestone_Task__c task25 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Place IP in Storage',
                                                 Order__c = 5, Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = false,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[11].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task25);
        
        Study_Template_Milestone_Task__c task26 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'Bag Details After IP Remove From Storage',
                                                 Order__c = 1, Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = false,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[12].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = false,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task26);
        
        Study_Template_Milestone_Task__c task27 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'IP Infusion Complete',
                                                 Order__c = 2, Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[12].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = true,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task27);
        
        Study_Template_Milestone_Task__c task28 =
            new Study_Template_Milestone_Task__c(Apheresis_Shipment__c = false,
                                                 Display_Name__c = 'IP Reconcilation Details',
                                                 Order__c = 1, Drug_Product_Shipment__c = false,
                                                 Read_Access_Queues__c = 'Logistics Co-ordinator', Site_Facing__c = true,
                                                 Sponsor_facing__c = true,
                                                 Study_Template_Milestone__c = studyTemplateMilestone[13].Id,
                                                 Task_Owner__c = 'Clinical Site User Queue', Verify__c = true,
                                                 Write_Access_Queues__c = 'Clinical Site');
        studyTemplateMilestoneTask.add(task28);
        
        insert studyTemplateMilestoneTask;
        
        List<Study_Template_Form__c> studyTemplateForm = new List<Study_Template_Form__c>();
        
        for (Integer i = 0; i < studyTemplateMilestoneTask.size(); i++) {
            Study_Template_Form__c form = new Study_Template_Form__c(Order__c = 1,
                                                                     Form_Name__c = studyTemplateMilestoneTask[i].Display_Name__c,
                                                                     Form_Title__c = studyTemplateMilestoneTask[i].Display_Name__c,
                                                                     Study_Template_Milestone_Task__c = studyTemplateMilestoneTask[i].Id);
            studyTemplateForm.add(form);
        }
        
        insert studyTemplateForm;
        
        for (Integer i = 0; i < studyTemplateMilestoneTask.size(); i++) {
            studyTemplateMilestoneTask[i].Study_Template_Form__c = studyTemplateForm[i].Id;
        }
        
        update studyTemplateMilestoneTask;
        
        List<Study_Template_Form_Section__c> studyTemplateFormSection = new List<Study_Template_Form_Section__c>();
        for (Integer i = 0; i < studyTemplateForm.size(); i++) {
            Study_Template_Form_Section__c formSec = new Study_Template_Form_Section__c(
                Form_Section_Name__c = studyTemplateForm[i].Form_Title__c,
                Study_Template_Form__c = studyTemplateForm[i].Id
            );
            studyTemplateFormSection.add(formSec);
        }
        
        insert studyTemplateFormSection;
        
        List<Study_Template_Form_Question__c> formQuestions = new List<Study_Template_Form_Question__c>();
        
        Study_Template_Form_Question__c question1 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[0].Id,
            Label__c = 'Slot Requested Date',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Date',
            Visible__c = TRUE,
            Slot_Booking_Task__c = TRUE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question2 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[1].Id,
            Label__c = 'Acknowledged?',
            Order__c = 1,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        List<Account> manufacturingSites = [SELECT Name FROM Account WHERE RecordTypeId =: Schema.SObjectType.Account.getRecordTypeInfosByName().get('Manufacturing Site').getRecordTypeId()];

        List<String> manufacturingSiteNames = new List<String>();
        for (Account site : manufacturingSites) {
            manufacturingSiteNames.add(site.Name);
        }
        String manufacturingSiteNamesCSV = String.join(manufacturingSiteNames, ', ');

        Study_Template_Form_Question__c question3 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[1].Id,
            Label__c = 'Select Manufacturing site',
            Order__c = 2,
            Picklist_Values__c = manufacturingSiteNamesCSV,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question4 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[2].Id,
            Label__c = 'Upload ICF',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'File',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question5 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[3].Id,
            Label__c = 'Subject ID',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Text',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = TRUE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question6 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[4].Id,
            Label__c = 'ICF',
            Order__c = 1,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question7 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[4].Id,
            Label__c = 'Eligibility Completed',
            Order__c = 2,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question8 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[5].Id,
            Label__c = 'Slot Booked',
            Order__c = 1,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question9 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[6].Id,
            Label__c = 'Select Courier',
            Order__c = 1,
            Picklist_Values__c = 'Manual, BioCair',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question10 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[7].Id,
            Label__c = 'Confirms COI',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Text',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question11 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[7].Id,
            Label__c = 'Confirms SID',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Text',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question12 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[7].Id,
            Label__c = 'Confirms YOB',
            Order__c = 3,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Text',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question13 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[8].Id,
            Label__c = 'DIN',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Text',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = TRUE
        );
        
        Study_Template_Form_Question__c question14 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[8].Id,
            Label__c = 'Subject Weight',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question15 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[8].Id,
            Label__c = 'Start Time',
            Order__c = 3,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Time',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question16 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[8].Id,
            Label__c = 'Stop Time',
            Order__c = 4,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Time',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question17 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[8].Id,
            Label__c = 'Collection Date',
            Order__c = 5,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Date',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question18 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[8].Id,
            Label__c = 'Volume Collected (200ml)',
            Order__c = 6,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question19 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[8].Id,
            Label__c = 'Total PBMC\'s Collected',
            Order__c = 7,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question20 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[8].Id,
            Label__c = 'Total Blood Volume Processed (10L)',
            Order__c = 8,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question21 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[9].Id,
            Label__c = 'Confirm COI',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Text',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question22 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[9].Id,
            Label__c = 'Confirm SID',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Text',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question23 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[9].Id,
            Label__c = 'Confirm YOB',
            Order__c = 3,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Text',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question24 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[10].Id,
            Label__c = 'Print AWB',
            Order__c = 1,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question25 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[11].Id,
            Label__c = 'Template Serial Number',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question26 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[12].Id,
            Label__c = 'Handover to Courier',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Checkbox',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question27 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[13].Id,
            Label__c = 'Apheresis Received',
            Order__c = 1,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question28 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[13].Id,
            Label__c = 'Manufacturing Start Date',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Date',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question29 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[13].Id,
            Label__c = 'Estimated Complete Date',
            Order__c = 3,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Date',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question30 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[14].Id,
            Label__c = 'Actual Manufacturing Date of Completion',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Date',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question31 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[14].Id,
            Label__c = 'Status of Manufacturing',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Text',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE,
            isManufacturingStatus__c = TRUE
        );
        
        Study_Template_Form_Question__c question32 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[15].Id,
            Label__c = 'No. of Bags',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question33 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[15].Id,
            Label__c = 'Select Courier',
            Order__c = 2,
            Picklist_Values__c = 'Manual, BioCair',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question34 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[16].Id,
            Label__c = 'Upload Certificate of Conformance',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'File',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question35 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[16].Id,
            Label__c = 'Confirm batch has been released',
            Order__c = 2,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question36 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[17].Id,
            Label__c = 'Dose Assigned',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question37 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[17].Id,
            Label__c = 'No of bags to ship',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question38 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[18].Id,
            Label__c = 'Print AWB',
            Order__c = 1,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question39 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[18].Id,
            Label__c = 'Packout Date',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Date',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question40 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[18].Id,
            Label__c = 'Packout Time',
            Order__c = 3,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Time',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question41 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[18].Id,
            Label__c = 'Packout Completed By',
            Order__c = 4,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Text',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question42 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[18].Id,
            Label__c = 'Serial Number of the Security Zip Tie',
            Order__c = 5,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question43 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[18].Id,
            Label__c = 'Shipper ID Number',
            Order__c = 6,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question44 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[18].Id,
            Label__c = 'Remarks',
            Order__c = 7,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Textarea',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question45 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[19].Id,
            Label__c = 'Handover to Courier',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Checkbox',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question46 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[20].Id,
            Label__c = 'Temperature Acceptance During Transport',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question47 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[20].Id,
            Label__c = 'Upload Temperature Report',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'File',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question48 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[21].Id,
            Label__c = 'Print Patient Record',
            Order__c = 1,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question49 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[21].Id,
            Label__c = 'Confirms Shipment ID/Tracking ID',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = TRUE,
            Required__c = TRUE,
            Type__c = 'Text',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question50 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[21].Id,
            Label__c = 'Did the LN2 Shipper Arrive Damaged?',
            Order__c = 3,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question51 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[21].Id,
            Label__c = 'Was a Temperature Excursion Identified for the Shipment in Transit?',
            Order__c = 4,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question52 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[21].Id,
            Label__c = 'Is There Inconsistency Between the Zip Tie Number Documented in Nexus vs. Zip Tie Attached to the Shipper?',
            Order__c = 5,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question53 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[22].Id,
            Label__c = 'What time was LN2 dewar opened?',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Time',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question54 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[22].Id,
            Label__c = 'Do number of bags received match number of bags shipped?',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Number',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question55 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[23].Id,
            Label__c = 'Does the IP appear to have thawed/started thawing?',
            Order__c = 1,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question56 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[23].Id,
            Label__c = 'Was the IP bag damaged/leaking?',
            Order__c = 2,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question57 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[23].Id,
            Label__c = 'Are the IP labels on the cassette and bag peeling/missing or illegible?',
            Order__c = 3,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question58 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[23].Id,
            Label__c = 'Is there a mismatch for any subject identifiers displayed on the IP labels on the cassette and bag?',
            Order__c = 4,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question59 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[24].Id,
            Label__c = 'Date IP is stored',
            Order__c = 1,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Date',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question60 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[24].Id,
            Label__c = 'Time IP is stored',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Time',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question61 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[24].Id,
            Label__c = 'Stored in?',
            Order__c = 3,
            Picklist_Values__c = 'LN2 freezer, LN2 dewar',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question62 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[25].Id,
            Label__c = 'Is the IP bag damaged/leaking?',
            Order__c = 1,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question63 = new Study_Template_Form_Question__c(
            Active__c = FALSE, // Not active
            Study_Template_Form_Section__c = studyTemplateFormSection[25].Id,
            Label__c = 'Does the subject ID and COI displayed on the IP bag label match?',
            Order__c = 2,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question64 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[26].Id,
            Label__c = 'Infusion Complete',
            Order__c = 1,
            Picklist_Values__c = 'Yes, No',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question65 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[26].Id,
            Label__c = 'Date infusion occurred',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Date',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        Study_Template_Form_Question__c question66 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[27].Id,
            Label__c = 'What is the final reconciliation of the bag?',
            Order__c = 1,
            Picklist_Values__c = 'Infused, Destroyed, Returned to sponsor',
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Picklist',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        
        Study_Template_Form_Question__c question67 = new Study_Template_Form_Question__c(
            Active__c = TRUE,
            Study_Template_Form_Section__c = studyTemplateFormSection[27].Id,
            Label__c = 'Date of reconciliation',
            Order__c = 2,
            Picklist_Values__c = NULL,
            Read_Only__c = FALSE,
            Required__c = TRUE,
            Type__c = 'Date',
            Visible__c = TRUE,
            Slot_Booking_Task__c = FALSE,
            Is_Subject__c = FALSE,
            Is_DIN__c = FALSE
        );
        
        formQuestions.add(question1);
        formQuestions.add(question2);
        formQuestions.add(question3);
        formQuestions.add(question4);
        formQuestions.add(question5);
        formQuestions.add(question6);
        formQuestions.add(question7);
        formQuestions.add(question8);
        formQuestions.add(question9);
        formQuestions.add(question10);
        formQuestions.add(question11);
        formQuestions.add(question12);
        formQuestions.add(question13);
        formQuestions.add(question14);
        formQuestions.add(question15);
        formQuestions.add(question16);
        formQuestions.add(question17);
        formQuestions.add(question18);
        formQuestions.add(question19);
        formQuestions.add(question20);
        formQuestions.add(question21);
        formQuestions.add(question22);
        formQuestions.add(question23);
        formQuestions.add(question24);
        formQuestions.add(question25);
        formQuestions.add(question26);
        formQuestions.add(question27);
        formQuestions.add(question28);
        formQuestions.add(question29);
        formQuestions.add(question30);
        formQuestions.add(question31);
        formQuestions.add(question32);
        formQuestions.add(question33);
        formQuestions.add(question34);
        formQuestions.add(question35);
        formQuestions.add(question36);
        formQuestions.add(question37);
        formQuestions.add(question38);
        formQuestions.add(question39);
        formQuestions.add(question40);
        formQuestions.add(question41);
        formQuestions.add(question42);
        formQuestions.add(question43);
        formQuestions.add(question44);
        formQuestions.add(question45);
        formQuestions.add(question46);
        formQuestions.add(question47);
        formQuestions.add(question48);
        formQuestions.add(question49);
        formQuestions.add(question50);
        formQuestions.add(question51);
        formQuestions.add(question52);
        formQuestions.add(question53);
        formQuestions.add(question54);
        formQuestions.add(question55);
        formQuestions.add(question56);
        formQuestions.add(question57);
        formQuestions.add(question58);
        formQuestions.add(question59);
        formQuestions.add(question60);
        formQuestions.add(question61);
        formQuestions.add(question62);
        formQuestions.add(question63);
        formQuestions.add(question64);
        formQuestions.add(question65);
        formQuestions.add(question66);
        formQuestions.add(question67);
        
        insert formQuestions;
    }
}