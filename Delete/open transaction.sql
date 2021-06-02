USE RegisterCases
GO
select  st.session_id
      , s.status
      , s.last_request_start_time
      , sum( dt.database_transaction_log_bytes_used + dt.database_transaction_log_bytes_used_system ) / 1024 / 1024 as mb_log_consumption
      , sum( dt.database_transaction_log_bytes_reserved + dt.database_transaction_log_bytes_reserved_system ) / 1024 / 1024 as mb_log_reserved
      , min( dt.database_transaction_last_lsn )
  from sys.dm_tran_active_transactions at 
  join sys.dm_tran_database_transactions dt 
    on dt.transaction_id = at.transaction_id 
  join sys.dm_tran_session_transactions st 
    on st.transaction_id = at.transaction_id 
  join sys.dm_exec_sessions s 
    on s.session_id = st.session_id
where dt.database_id = db_id()
group by st.session_id, s.status, s.last_request_start_time
order by min(dt.database_transaction_last_lsn);