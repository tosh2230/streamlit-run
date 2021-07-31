from datetime import datetime
import streamlit as st
import numpy as np
import pandas as pd


def create_df():
    return pd.DataFrame(np.arange(1000).reshape(200, 5), columns=['a', 'b', 'c', 'd', 'e'])

def show(df):
    num = 400
    title = 'Sample DataFrame'
    selected_charactor = 'Tom'
    dt_now = datetime.now()
    dt_str = dt_now.strftime('%Y-%m-%d %H:%M:%S')
    date_str = dt_now.strftime('%Y-%m-%d')
    time_str = dt_now.strftime('%H:%M:%S')
    selected_items = list(df.columns.values)
    num = 250
    multi_num = (0, 250)

    is_checked = st.sidebar.checkbox('Select parameters', value=False)

    if is_checked:
        selected_charactor = st.sidebar.selectbox('Select a charactor', ['Tom', 'Jerry'])
        date_str = st.sidebar.date_input("Pick a date")
        time_str = st.sidebar.time_input("Pick a time")
        title = st.sidebar.text_input("Write a title", value='Sample DataFrame')
        selected_items = st.sidebar.multiselect('Select columns', list(df.columns.values), selected_items)
        num = st.sidebar.slider("Pick a row size", 0, 500, num)
        multi_num = st.sidebar.slider("Pick row range", 0, 250, multi_num)

    st.header(f'Hello, {selected_charactor}!')
    st.write(f'Now: {dt_str}')
    st.write(f'Selected: {date_str} {time_str}')
    df_filtered = df.loc[multi_num[0]:multi_num[1], selected_items]

    st.title(title)
    st.button('Reload')

    body_col1, body_col2 = st.beta_columns(2)
    with body_col1:
        st.title('01')
        st.dataframe(df_filtered, width=500, height=num)
    with body_col2:
        st.title('02')
        st.dataframe(df_filtered, width=500, height=num)

if __name__ == '__main__':
    show(create_df())
