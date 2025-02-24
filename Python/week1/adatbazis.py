import sqlite3

def kapcsolodas():
    connection = sqlite3.connect("szotar.db")
    return connection

def kapcsolat_zarasa(connection : sqlite3.Connection):
    connection.close()

def tabla_keszites():
    TABLE_DEF = """
        CREATE TABLE IF NOT EXISTS "szotar" (
        "magyar" TEXT,
        "angol" TEXT
        )
    """
    conn = kapcsolodas()
    conn.execute(TABLE_DEF)
    kapcsolat_zarasa(conn)

def rogzites(magyar,angol):
    conn = kapcsolodas()
    statement = "INSERT INTO szotar (magyar, angol) VALUES (?,?)"
    cursor = conn.cursor()
    cursor.execute(statement, (magyar, angol) )
    conn.commit()
    kapcsolat_zarasa(conn)

def kereses(szo, is_magyar=True):
    conn = kapcsolodas()
    if is_magyar:
        statement = "SELECT angol FROM szotar WHERE magyar = ?"
    else:
        statement = "SELECT magyar FROM szotar WHERE angol = ?"

    cursor = conn.cursor()
    result = cursor.execute(statement, (szo,) )
    result_list = []
    for row in result.fetchall():
        result_list.append(row[0])
    kapcsolat_zarasa(conn)
    return result_list