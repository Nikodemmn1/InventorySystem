Its_Load_Item_Classes()
{
    mysql_query("SELECT * FROM `mru_item_classes`");
    mysql_store_result();
    
    new rowString[384];
    new classID, itemSize;
    while(mysql_fetch_row_format(rowString, "|"))
    {
        sscanf(rowString, "p<|>dd", classID, itemSize);

        if(classID >= ITS_IC_CLASS_LIMIT)
        {
            printf("Za duzo klas przedmiotow i kontenerow (classID = %d) - zwieksz ITS_IC_CLASS_LIMIT w kodzie!", classID);
		    SendRconCommand("exit");
		    return 1;
        }

        itsClassesBI[classID][ITS_CL_BI_ITEMSIZE] = itemSize;
        itsClassesBI[classID][ITS_CL_BI_RELCONTCLASS] = ITS_NULL;

        Bit_Let(itsClassesBIUsed, classID);
    }
    
    mysql_free_result();

    return 1;
}

Its_Load_Container_Classes()
{
    mysql_query("SELECT * FROM `mru_container_classes`");
    mysql_store_result();
    
    new rowString[384];
    new classID, containerSize, emptyItemClass = ITS_NULL;
    while(mysql_fetch_row_format(rowString, "|"))
    {
        sscanf(rowString, "p<|>ddd", classID, containerSize, emptyItemClass);

        if(classID >= ITS_IC_CLASS_LIMIT)
        {
            printf("Za duzo klas przedmiotow i kontenerow (classID = %d) - zwieksz ITS_IC_CLASS_LIMIT w kodzie!", classID);
		    SendRconCommand("exit");
		    return 1;
        }

        itsClassesBC[classID][ITS_CL_BC_CONTAINERSIZE] = containerSize;
        itsClassesBC[classID][ITS_CL_BC_EMPTYITEMCLASS] = emptyItemClass;

        if(emptyItemClass != ITS_NULL)
        {
            itsClassesBI[emptyItemClass][ITS_CL_BI_RELCONTCLASS] = classID;
        }

        Bit_Let(itsClassesBCUsed, classID);
    }
    
    mysql_free_result();

    return 1;

}

Its_Load_Classes_Attach_Bones()
{
    mysql_query("SELECT * FROM `mru_ic_class_attach_info`");
    mysql_store_result();

    new rowString[384];
    new classID, bonesAllowed[18];

    while(mysql_fetch_row_format(rowString, "|"))
    {
        sscanf(rowString, "p<|>da<d>[18]", classID, bonesAllowed);

        for(new boneIdx = 0; boneIdx < sizeof(bonesAllowed); boneIdx++)
        {
            Bit_Set(itsClassesIC[classID][ITS_CL_IC_ATTACH_BONES], boneIdx+1, bool:bonesAllowed[boneIdx]);
        }

        if(Bit_GetCount(itsClassesIC[classID][ITS_CL_IC_ATTACH_BONES]) > 0)
        {
            itsClassesIC[classID][ITS_CL_IC_ISATTACHABLE] = true;
        }
    }

    mysql_free_result();

    return 1;
}

Its_Load_Classes()
{
    mysql_query("SELECT * FROM `mru_item_and_container_classes`");
    mysql_store_result();
    
    new rowString[384];
    new classID, classTmp[e_ITS_CLASS];

    while(mysql_fetch_row_format(rowString, "|"))
    {
        sscanf(rowString, "p<|>de<ds["#ITS_CNAME_SIZE"]s["#ITS_FRIENDLYNAME_SIZE"]ll>D(-1)",
            classID,
            classTmp,
            classTmp[ITS_CL_IC_MODELID]
        );
        
        if(classID >= ITS_IC_CLASS_LIMIT)
        {
            printf("Za duzo klas przedmiotow i kontenerow (classID = %d) - zwieksz ITS_IC_CLASS_LIMIT w kodzie!", classID);
		    SendRconCommand("exit");
		    return 0;
        }

        if(!Bit_Get(itsCategoriesUsed, classTmp[ITS_CL_IC_CATEGORY]))
        {
            printf("Kategoria (ID:%d) odczytana przy wczytywaniu klasy (ID:%d) z bazy SQL nie istnieje!", classTmp[ITS_CL_IC_CATEGORY], classID);
		    SendRconCommand("exit");
            return 0;
        }

        classTmp[ITS_CL_IC_ISATTACHABLE] = false;
        Bit_SetAll(classTmp[ITS_CL_IC_ATTACH_BONES], false);

        WritePhysMemory(_:MEM_UM_get_addr(itsClassesIC[classID][e_ITS_CLASS:0]), classTmp, _:e_ITS_CLASS);
        Bit_Let(itsClassesICUsed, classID);
    }

    mysql_free_result();

    Its_Load_Classes_Attach_Bones();

    Its_Load_Item_Classes();
    Its_Load_Container_Classes();

    return 1;
}