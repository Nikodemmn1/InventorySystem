#pragma warning push
#pragma warning disable 203
Its_Unload_IC(dbID, propagate = true)
{
    printf("Its_Unload_IC dbID: %d", dbID);
    new cID = map_str_get(itsCategoryIDByTag, "IC");
    Its_Unplace(dbID);
    Its_Pop(dbID, cID);
    return 1;
}
#pragma warning pop

Its_Unload_BC(dbID, propagate = true)
{
    printf("Its_Unload_BC dbID: %d", dbID);

    if(propagate)
    {
        Its_Unload_IC(dbID);
    }

    new List:itemsList = List:Its_Get(dbID, ITS_BC_CONT_ITEMS);
    for(new i = 0; i < list_size(itemsList); i++)
    {
        new itemDbId = list_get(itemsList, i);
        new Func:itemDelFunc<d> = Func:Its_Get(itemDbId, ITS_FUNC_DELETE)<d>;
        printf("Its_Unload_BC REC itemDbId: %d", itemDbId);
        @.itemDelFunc(itemDbId);
    }
    list_delete(List:Its_Get(dbID, ITS_BC_CONT_ITEMS));

    Its_Pop_By_Tag(dbID, "BC");

    return 1;
}

Its_Unload_BI(dbID, propagate = true)
{
    printf("Its_Unload_BI dbID: %d", dbID);
    Its_Remove_Item_From_Container(dbID);

    if(propagate)
    {
        Its_Unload_IC(dbID);
    }

    Its_Pop_By_Tag(dbID, "BI");

    return 1;
}

#pragma warning push
#pragma warning disable 203
Its_Unload_POS(dbID, propagate = true)
{
    printf("Its_Unload_POS dbID: %d", dbID);

    Its_Pop_By_Tag(dbID, "POS");

    return 1;
}
#pragma warning pop

Its_Unload_PC(dbID, propagate = true)
{
    printf("Its_Unload_PC dbID: %d", dbID);

    if(propagate)
    {
        Its_Unload_BC(dbID);
    }

    Its_Pop_By_Tag(dbID, "PC");
    
    return 1;
}

#pragma warning push
#pragma warning disable 203
Its_Unload_SPMOD(dbID, propagate = true)
{
    printf("Its_Unload_SPMOD dbID: %d", dbID);

    Its_Pop_By_Tag(dbID, "SPMOD");
    
    return 1;
}
#pragma warning pop
