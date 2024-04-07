#pragma warning push
#pragma warning disable 203
Its_IC_InsQBuild(uninsDbId, insertTmpQ[], newDbId)
{
    return format(insertTmpQ, INSERT_SINGLE_SIZE, "(DEFAULT, %d), ", Its_Get(uninsDbId, ITS_IC_CLASSID));
}
#pragma warning pop

Its_BI_InsQBuild(uninsDbId, insertTmpQ[], newDbId)
{
    format(insertTmpQ, INSERT_SINGLE_SIZE, "(%d, %d, ", 
        newDbId, 
        Its_Get(uninsDbId, ITS_BI_ISPERMAMENT));
    
    new parentContainer = Its_Get(uninsDbId, ITS_BI_PARENTCONTAINER);
    if(parentContainer == ITS_NULL)
    {
        strcat(insertTmpQ, "NULL), ", INSERT_SINGLE_SIZE);
    }
    else
    {
        format(insertTmpQ, INSERT_SINGLE_SIZE, "%s%d), ", insertTmpQ, parentContainer);
    }
    return 1;
}

Its_POS_InsQBuild(uninsDbId, insertTmpQ[], newDbId)
{
    format(insertTmpQ, INSERT_SINGLE_SIZE, "(%d, %f, %f, %f, %d, %d, ", 
        newDbId, 
        Float:Its_Get(uninsDbId, ITS_POS_X),
        Float:Its_Get(uninsDbId, ITS_POS_Y),
        Float:Its_Get(uninsDbId, ITS_POS_Z),
        Its_Get(uninsDbId, ITS_POS_INTERIOR),
        Its_Get(uninsDbId, ITS_POS_VW));
    
    new ownerID = Its_Get(uninsDbId, ITS_POS_OWNERID);
    if(ownerID == ITS_NULL)
    {
        strcat(insertTmpQ, "NULL), ", INSERT_SINGLE_SIZE);
    }
    else
    {
        format(insertTmpQ, INSERT_SINGLE_SIZE, "%s%d), ", insertTmpQ, ownerID);
    } 

    return 1;
}

Its_PC_InsQBuild(uninsDbId, insertTmpQ[], newDbId)
{
    return format(insertTmpQ, INSERT_SINGLE_SIZE, "(%d, %d), ", 
        newDbId, 
        Its_Get(uninsDbId, ITS_PC_UID));
}

Its_SPMOD_InsQBuild(uninsDbId, insertTmpQ[], newDbId)
{
    return format(insertTmpQ, INSERT_SINGLE_SIZE, "(%d, %d), ",
        newDbId,
        Its_Get(uninsDbId, ITS_SPMOD_MODELID));
}

Its_ATP_InsQBuild(uninsDbId, insertTmpQ[], newDbId)
{
    return format(insertTmpQ, INSERT_SINGLE_SIZE, "(%d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %d, %d), ",
        newDbId,
        Its_Get(uninsDbId, ITS_ATP_UID),
        Float:Its_Get(uninsDbId, ITS_ATP_X),
        Float:Its_Get(uninsDbId, ITS_ATP_Y),
        Float:Its_Get(uninsDbId, ITS_ATP_Z),
        Float:Its_Get(uninsDbId, ITS_ATP_RX),
        Float:Its_Get(uninsDbId, ITS_ATP_RY),
        Float:Its_Get(uninsDbId, ITS_ATP_RZ),
        Float:Its_Get(uninsDbId, ITS_ATP_SX),
        Float:Its_Get(uninsDbId, ITS_ATP_SY),
        Float:Its_Get(uninsDbId, ITS_ATP_SZ),
        Its_Get(uninsDbId, ITS_ATP_BONE),
        Its_Get(uninsDbId, ITS_ATP_ISACTIVE));
}