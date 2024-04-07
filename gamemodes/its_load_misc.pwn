Its_Load_Item_Or_Cont(dbID)
{
    new query[512];
    format(query, sizeof(query), "%s WHERE ic.ID = %d", ITS_SELECT_QUERY_BASE, dbID);
    return Its_Load(query, false);
}

Its_Load_Items_In_Container(containerDbID, recursive = true)
{
    new query[512];
    format(query, sizeof(query), "%s WHERE i.CONTAINERID = %d", ITS_SELECT_QUERY_BASE, containerDbID);
    printf("loading in container %d", containerDbID);
    return Its_Load(query, recursive);
}

Its_Load_Placed(recursive = true)
{
    new query[512];
    format(query, sizeof(query), "%s WHERE p.ID IS NOT NULL", ITS_SELECT_QUERY_BASE);
    return Its_Load(query, recursive);
}

Its_Load_Player_Container(uid, recursive = true)
{
    new query[512], List:loadedIds, loadedID = ITS_NULL;

    format(query, sizeof(query), "%s WHERE pc.PLAYERUID = %d", ITS_SELECT_QUERY_BASE, uid);
    Its_Load(query, recursive, loadedIds);

    if(list_size(loadedIds) == 1)
    {
        loadedID = list_get(loadedIDs, 0);
    }
    list_delete(loadedIDs);

    return loadedID;
}
