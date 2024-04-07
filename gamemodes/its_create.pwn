__Its_Create_IC(classID, isContainer)
{
    Its_Push_IC(nextUninsertedDbId++, classID, isContainer);
    //printf("Stworzono przedmiot/kontener o ID %d (classID = %d, isContainer = %d)!", nextUninsertedDbId - 1, classID, isContainer); //TODO: WYWAL!!!
    return nextUninsertedDbId - 1;
}

Its_Create_BC(classID)
{
    new dbID = __Its_Create_IC(classID, true);
    Its_Push_BC(dbID, list_new(), 0);

    return dbID;
}

Its_Create_BI(classID, isPermament, parentContainer)
{
    new dbID = __Its_Create_IC(classID, false);
    Its_Push_BI(dbID, isPermament, parentContainer);
    
    if(parentContainer != ITS_NULL)
    {
        __Its_Append_To_Container(dbID, parentContainer);
    }

    //printf("Stworzono przedmiot o ID %d (isPermament = %d, parentContainer = %d)!", dbID, isPermament, parentContainer); //TODO: WYWAL!!!

    return dbID;
}

Its_Create_POS(dbID, Float:x, Float:y, Float:z, interior, vw, ownerID)
{
    if(dbID < ITC_UNINSERTED)
    {
        list_add(itsCategoriesByTag["POS"][ITS_TO_INSERT_ADDITIONAL], dbID);
    }
    Its_Push_POS(dbID, x, y, z, interior, vw, ownerID);
    //printf("Stworzono POS o ID %d (x = %f, y = %f, z = %f, interior = %d, vw = %d, ownerID = %d)!", dbID, x, y, z, interior, vw, ownerID); //TODO: WYWAL!!!
    return dbID;
}

Its_Create_PC(uid)
{
    new dbID = Its_Create_BC(1);
    Its_Push_PC(dbID, uid);
    map_add(UIDToContID, uid, dbID); //TODO: USUN
    //printf("Stworzono kontener gracza o ID %d (uid = %d)!", dbID, uid); //TODO: WYWAL!!!
    return dbID;
}

Its_Create_SPMOD(dbID, modelID)
{
    if(dbID < ITC_UNINSERTED)
    {
        list_add(itsCategoriesByTag["SPMOD"][ITS_TO_INSERT_ADDITIONAL], dbID);
    }
    Its_Push_SPMOD(dbID, modelID);
    printf("Stworzono SPMOD o ID %d (modelID = %d)!", dbID, modelID); //TODO: WYWAL!!!
    return dbID;
}

Its_Create_ATP(dbID, uid, Float:x, Float:y, Float:z, Float:rx, Float:ry, Float:rz, Float:sx, Float:sy, Float:sz, bone, isActive, index)
{
    if(dbID < ITC_UNINSERTED)
    {
        list_add(itsCategoriesByTag["ATP"][ITS_TO_INSERT_ADDITIONAL], dbID);
    }
    Its_Push_ATP(dbID, uid, x, y, z, rx, ry, rz, sx, sy, sz, bone, isActive, index);
    printf("Stworzono ATP o ID %d ()!", dbID); //TODO: WYWAL!!!
    return dbID;
}