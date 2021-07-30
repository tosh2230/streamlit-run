import streamlit as st
import numpy as np
import pandas as pd


def get_data_source():
    return pd.DataFrame(np.arange(20).reshape(4, 5))

def show(df):
    st.title('sample dataframe')
    st.dataframe(df,width=500,height=250)

if __name__ == '__main__':
    show(get_data_source())
