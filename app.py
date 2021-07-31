from datetime import datetime
import streamlit as st
import numpy as np
import pandas as pd
import plotly.express as px

row_size = 1000
graph_width = 750
bins = 20

def create_df():
    return pd.DataFrame(np.random.rand(row_size, 5), columns=['a', 'b', 'c', 'd', 'e'])

def show(df):
    # initialize
    selected_charactor = 'World'
    header = 'Sample DataFrame'
    dt_now = datetime.now()
    dt_str = dt_now.strftime('%Y-%m-%d %H:%M:%S')
    date_str = dt_now.strftime('%Y-%m-%d')
    time_str = dt_now.strftime('%H:%M:%S')
    selected_items = list(df.columns.values)
    details_window_length = 250
    multi_num = (0, row_size)

    # sidebar
    st.sidebar.button('Reload')
    is_checked = st.sidebar.checkbox('Select parameters', value=False)

    if is_checked:
        selected_charactor = st.sidebar.selectbox('Select a charactor', ['World', 'Tom', 'Jerry'], index=0)
        date_str = st.sidebar.date_input("Pick a date")
        time_str = st.sidebar.time_input("Pick a time")
        header = st.sidebar.text_input("Write a header text", value=header)
        selected_items = st.sidebar.multiselect('Select columns', list(df.columns.values), selected_items)
        details_window_length = st.sidebar.slider("Pick a details window size", 0, 500, details_window_length)
        multi_num = st.sidebar.slider("Pick row range", 0, row_size, multi_num)        

    st.title(f'Hello, {selected_charactor}!')

    col1, col2 = st.beta_columns(2)
    with col1:
        st.write(f'Now: {dt_str}')
    with col2:
        st.write(f'Selected: {date_str} {time_str}')

    st.header(header)
    df_filtered = df.loc[multi_num[0]:multi_num[1], selected_items]

    with st.beta_expander('Show describe'):
        st.dataframe(df_filtered.describe(), width=750, height=250)

    with st.beta_expander('Show details'):
        st.dataframe(df_filtered, width=750, height=details_window_length)

    st.header('Graphs')

    line_chart = px.line(df_filtered, width=graph_width, title='Line chart')
    st.write(line_chart)

    box_plot = px.box(df_filtered, y=list(df_filtered.columns), width=graph_width, title='Box plot')
    st.write(box_plot)

    histogram = px.histogram(df_filtered, nbins=bins, width=graph_width, title='Histogram: ALL')
    st.write(histogram)

    for col in list(df_filtered.columns):
        hist_fig = px.histogram(df_filtered[col], x=col, nbins=bins, width=graph_width, title=f'Histogram: {col}')
        st.write(hist_fig)

if __name__ == '__main__':
    show(create_df())
