// columnNumber w poni¿szych funkcjach nie uwzglêdnia kolumny 'ID', indeksowane od 0

__Its_UpdQBuild_Column_Int(dbID, val, columnNumber, querySize, tmpQueries, tmpQueriesLens[ITS_SQL_MAX_COLUMNS+1], tmpStr[UPDATE_QUERY_SIZE])
{
    new tmpStrLen;
    format(tmpStr, sizeof(tmpStr), "WHEN %d THEN %d ", dbID, val);
    tmpStrLen = strlen(tmpStr);
    MEM_UM_set_arr(UnmanagedPointer:tmpQueries, columnNumber * querySize + tmpQueriesLens[columnNumber], tmpStr, tmpStrLen);
    tmpQueriesLens[columnNumber] += tmpStrLen;

    return 1;
}

__Its_UpdQBuild_Column_Float(dbID, Float:val, columnNumber, querySize, tmpQueries, tmpQueriesLens[ITS_SQL_MAX_COLUMNS+1], tmpStr[UPDATE_QUERY_SIZE])
{
    new tmpStrLen;
    format(tmpStr, sizeof(tmpStr), "WHEN %d THEN %f ", dbID, val);
    tmpStrLen = strlen(tmpStr);
    MEM_UM_set_arr(UnmanagedPointer:tmpQueries, columnNumber * querySize + tmpQueriesLens[columnNumber], tmpStr, tmpStrLen);
    tmpQueriesLens[columnNumber] += tmpStrLen;

    return 1;
}

__Its_UpdQBuild_Column_Str(dbID, const val[], columnNumber, querySize, tmpQueries, tmpQueriesLens[ITS_SQL_MAX_COLUMNS+1], tmpStr[UPDATE_QUERY_SIZE])
{
    new tmpStrLen;
    format(tmpStr, sizeof(tmpStr), "WHEN %d THEN %s ", dbID, val);
    tmpStrLen = strlen(tmpStr);
    MEM_UM_set_arr(UnmanagedPointer:tmpQueries, columnNumber * querySize + tmpQueriesLens[columnNumber], tmpStr, tmpStrLen);
    tmpQueriesLens[columnNumber] += tmpStrLen;

    return 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Its_IC_UpdQBuild(dbID, querySize, tmpQueries, tmpQueriesLens[ITS_SQL_MAX_COLUMNS+1], tmpStr[UPDATE_QUERY_SIZE])
{
    __Its_UpdQBuild_Column_Int(dbID, Its_Get(dbID, ITS_IC_CLASSID), 0, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    return 1;
}

Its_BI_UpdQBuild(dbID, querySize, tmpQueries, tmpQueriesLens[ITS_SQL_MAX_COLUMNS+1], tmpStr[UPDATE_QUERY_SIZE])
{
    __Its_UpdQBuild_Column_Int(dbID, Its_Get(dbID, ITS_BI_ISEQUIPPED), 0, querySize, tmpQueries, tmpQueriesLens, tmpStr);

    new parentContainer = Its_Get(dbID, ITS_BI_PARENTCONTAINER);
    if(parentContainer == ITS_NULL)
    {
        __Its_UpdQBuild_Column_Str(dbID, "NULL", 1, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    }
    else
    {
        __Its_UpdQBuild_Column_Int(dbID, parentContainer, 1, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    }
    
    return 1;
}

Its_POS_UpdQBuild(dbID, querySize, tmpQueries, tmpQueriesLens[ITS_SQL_MAX_COLUMNS+1], tmpStr[UPDATE_QUERY_SIZE])
{
    __Its_UpdQBuild_Column_Float(dbID, Float:Its_Get(dbID, ITS_POS_X), 0, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    __Its_UpdQBuild_Column_Float(dbID, Float:Its_Get(dbID, ITS_POS_Y), 1, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    __Its_UpdQBuild_Column_Float(dbID, Float:Its_Get(dbID, ITS_POS_Z), 2, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    __Its_UpdQBuild_Column_Int(dbID, Its_Get(dbID, ITS_POS_INTERIOR), 3, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    __Its_UpdQBuild_Column_Int(dbID, Its_Get(dbID, ITS_POS_VW), 4, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    
    new ownerID = Its_Get(dbID, ITS_POS_OWNERID);
    if(ownerID == ITS_NULL)
    {
        __Its_UpdQBuild_Column_Str(dbID, "NULL", 5, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    }
    else
    {
        __Its_UpdQBuild_Column_Int(dbID, ownerID, 5, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    }

    return 1;
}

Its_PC_UpdQBuild(dbID, querySize, tmpQueries, tmpQueriesLens[ITS_SQL_MAX_COLUMNS+1], tmpStr[UPDATE_QUERY_SIZE])
{
    __Its_UpdQBuild_Column_Int(dbID, Its_Get(dbID, ITS_PC_UID), 0, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    return 1;
}

Its_SPMOD_UpdQBuild(dbID, querySize, tmpQueries, tmpQueriesLens[ITS_SQL_MAX_COLUMNS+1], tmpStr[UPDATE_QUERY_SIZE])
{
    __Its_UpdQBuild_Column_Int(dbID, Its_Get(dbID, ITS_SPMOD_MODELID), 0, querySize, tmpQueries, tmpQueriesLens, tmpStr);
    return 1;   
}
