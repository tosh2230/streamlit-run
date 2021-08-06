from datetime import datetime

import numpy as np
import pandas as pd
import plotly.express as px
import streamlit as st

row_size = 10000
bins = 20

@st.cache
def create_df():
    df = pd.DataFrame(np.random.rand(row_size, 1), columns=['a'])
    df['b'] = df['a']**2
    df['c'] = np.exp(df['b'])
    return df

def show(df):
    # initialize
    title = 'Streamlit Sample'
    dt_now = datetime.now()
    dt_str = dt_now.strftime('%Y-%m-%d %H:%M:%S')
    date_str = dt_now.strftime('%Y-%m-%d')
    time_str = dt_now.strftime('%H:%M:%S')
    selected_items = list(df.columns.values)
    histogram_mode = 'relative'
    graph_height = 640
    graph_width = 800
    details_window_length = 250
    multi_num = (0, row_size)

    # sidebar
    st.sidebar.button('Reload')
    is_checked = st.sidebar.checkbox('Select parameters', value=False)

    if is_checked:
        multi_num = st.sidebar.slider("Pick row range", 0, row_size, multi_num)
        selected_items = st.sidebar.multiselect('Select columns', list(df.columns.values), selected_items)
        graph_height = st.sidebar.number_input("Set graph height", 0, 1000, graph_height)
        graph_width = st.sidebar.number_input("Set graph width", 0, 1000, graph_width)
        histogram_mode = st.sidebar.selectbox('Select a histogram mode', ['relative', 'overlay'], index=0)

        with st.sidebar.beta_expander('Show others'):
            date_str = st.date_input("Pick a date")
            time_str = st.time_input("Pick a time")
            title = st.text_input("Change a title text", value=title)

    # Title
    st.title(title)

    col1, col2 = st.beta_columns(2)
    with col1:
        st.write(f'Now: {dt_str}')
    with col2:
        st.write(f'Selected: {date_str} {time_str}')

    # DataFrame
    st.header('DataFrame')
    df_filtered = df.loc[multi_num[0]:multi_num[1], selected_items]

    with st.beta_expander('Show describe'):
        st.dataframe(df_filtered.describe(), height=250, width=graph_width)

    with st.beta_expander('Show details'):
        details_window_length = st.slider("Set window size", 0, 500, details_window_length)
        st.dataframe(df_filtered, height=details_window_length, width=graph_width)

    # Graphs
    st.header('Graphs')

    line_chart = px.line(df_filtered, height=graph_height, width=graph_width, title='Line chart')
    st.write(line_chart)

    box_plot = px.box(df_filtered, y=list(df_filtered.columns), height=graph_height, width=graph_width, title='Box plot')
    st.write(box_plot)

    histogram = px.histogram(df_filtered, nbins=bins, height=graph_height, width=graph_width, opacity=0.5, barmode=histogram_mode, title=f'Histogram: {histogram_mode}')
    histogram.update_layout(bargap=0.1)
    st.write(histogram)

    scatter = px.scatter(df_filtered, height=graph_height, width=graph_width, opacity=0.5, title='Scatter plot')
    st.write(scatter)

    df_iris = px.data.iris()
    scatter_matrix = px.scatter_matrix(df_iris, dimensions=["sepal_width", "sepal_length", "petal_width", "petal_length"], color="species", height=graph_height, width=graph_width, opacity=0.5, title='Scatter matrix (Iris)')
    st.write(scatter_matrix)

if __name__ == '__main__':
    show(create_df())
