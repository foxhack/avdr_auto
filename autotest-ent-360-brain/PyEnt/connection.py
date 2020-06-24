import mysql.connector as msql
import SSHLibrary

class MySql(object):
    def __init__(self, target, username='hansight', pwd='HanS!gh5#NT', db='hansight', port_num=3399):
        self.conn=msql.connect(host=target, user=username, password=pwd, database=db, use_unicode=True, port=port_num)
    
    def execute_sql_cmd(self, sql_cmd):
        self.cursor = self.conn.cursor()
        self.cursor.execute(sql_cmd)
        if self.cursor.rowcount < 0:
            output = self.cursor.fetchall()
            self.cursor.close()
            return output[0][0]
        else:
            self.conn.commit()
            self.cursor.close()

    def query_table_field(self, field, table, condition='1=1'):
        query_cmd = "select %s from %s where %s" % (field, table, condition)
        return self.execute_sql_cmd(query_cmd)

    def query_log_count(self, table, condition='1=1'):
        query_cmd = "select count(*) from %s where %s" % (table, condition)
        return self.execute_sql_cmd(query_cmd)


class SSH(object):
    def __init__(self, host, username='root', password='hansight'):
        self.host = host
        self.user = username
        self.pwd = password
        self.ssh = None

    def open_connection(self):
        if not self.ssh:
            self.ssh = SSHLibrary.SSHLibrary()
            self.ssh.open_connection(self.host)
            self.ssh.login(self.user, self.pwd)

    def close_connection(self):
        self.ssh.close_all_connections()

    def execute_remote_cmd(self, cmd):
        self.open_connection()
        output = self.ssh.execute_command(cmd)
        return output

class Redis(object):
    def __init__(self, host):
        pass