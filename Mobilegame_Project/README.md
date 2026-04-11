---
title: "RF_Report"
output: html_document
date: "2025-11-26"
---
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
library(DT)
library(skimr)
library(tidyverse) # dplyr,ggplot2,tidyr,readr,purrr,stringr,forcats,tibble
library(psych)
library(recipes)
library(tibble)
library(fastDummies)
library(recipes)
library(naniar)
library(corrplot)
library(car)
library(dunn.test) 

library(tidymodels) 
library(ranger) # Random Forest 的高效引擎

library(forcats) # 為了 fct_reorder

# 字體設定
library(showtext)  
font_add_google("Noto Sans TC", "NotoSansTC") #安裝字體
font_families() #確認安裝的字體
showtext_auto(enable=TRUE) #啟動showtext
par(family = 'NotoSansTC') #指定字體

#轉pdf
library(tinytex) 
library(pagedown)
#html_to_pdf("HW21.html","HW21.pdf")
#options(tinytex.verbose = TRUE) #轉pdf需要
```


```{r 載入資料, echo = FALSE}
df <- read.csv("/Users/aditi/Documents/移動遊戲玩家分群與商業策略分析/data/raw/mobile_game_inapp_purchases.csv") 
```

```{r preview-head, echo=FALSE}
# 確保只顯示前 10 行
datatable(
  head(df, 10), 
  caption = "表 1.1：數據集的前 10 筆觀測值", # 加上標題
  options = list(
    pageLength = 10,  # 設定只顯示 10 行
    searching = FALSE # 隱藏搜尋欄位，讓表格看起來更乾淨
  ),
  rownames = FALSE # 隱藏行號 (可選)
)
```


```{r preview-tail, echo=FALSE}
datatable(
  tail(df, 10), 
  caption = "表 1.2：數據集的後 10 筆觀測值", 
  options = list(
    pageLength = 10,
    searching = FALSE 
  ),
  rownames = FALSE
)
```

## Review the data

```{r 檢視資料維度, echo = FALSE}
cat("Dataset Shape:",dim(df))
cat("\nDataset Info:")
datatable(str(df))
```

```{r 描述性統計, echo = FALSE}
cat("\nSummary Statistics (Numerical):")
print(describe(df))
# summary(df) R原始的
```
## 數值欄位分佈
```{r Basic distributions for numerical features, warning = FALSE, echo=FALSE} 
# 抓數值欄位
num_df <- df %>%
  select(where(is.numeric)) 
num_col <- names(num_df)

# 迴圈
walk(num_col, function(col_name) {
  
  # 建立單一圖表
  p <- ggplot(df, aes(x = .data[[col_name]])) +    # 在 aes() 中使用 .data[[col_name]]
    geom_histogram(aes(y = after_stat(density)), 
                   fill = "steelblue", alpha = 0.7, bins = 30) +
    geom_density(color = "red", linewidth = 1) +
    
    # 標題應該是針對單一欄位的
    labs(title = paste("Distribution of", col_name), 
         x = col_name, y = "Density") +
    theme_minimal()
    print(p)
})

```

## 類別欄位分佈
```{r Unique values and counts for categorical features, echo=FALSE}
# 抓出類別
chr_df <- df %>%
  select(where(is.character))
chr_df <- select(chr_df, -LastPurchaseDate, -UserID)
chr_col <- names(chr_df)

# 迴圈
walk(chr_col, function(col_name) {
  # 頻率表
  cat("\nUnique values in :",col_name)
  freq_table <- table(chr_df[[col_name]])
  print(freq_table)
  uni_value <- length(freq_table)
  cat("\n", col_name,"uni_value :",uni_value,"\n-----------------------------------------------------------------------------------------------")
  # 長條圖
  bar_plot <- ggplot(chr_df, aes(x = fct_infreq(.data[[col_name]]))) +
      geom_bar(fill = "steelblue") +
      # 疊加文字標籤
      geom_text(
      # 關鍵 1: y 軸位置設為長條圖的高度 (count)
      aes(y = after_stat(count),
        
        # 標籤內容設為百分比
        label = paste0(
          # 計算當前 count 佔總 count 的比例，並格式化為百分比
          round(after_stat(count) / sum(after_stat(count)) * 100, 1), 
          "%"
        )),
    stat = "count",   # 必須告訴 geom_text，它也要使用計算出的 "count" 統計量
    vjust = -0.5,     # 垂直調整：將文字稍微放在長條圖的上方
    size = 2.5        # 字體大小
  ) +
      labs(
        title = paste("Bar Chart for:", col_name),
        x = col_name,
        y = "Count"
      ) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) # 旋轉 X 軸標籤
    
    # 顯示圖形
    #    在 RStudio 中，這會將圖形輸出到右下角的 "Plots" 窗格
    print(bar_plot)
  
  })

```


```{r 檢視時間欄位, echo = FALSE}
# Check for any date parsing needed
str(df$LastPurchaseDate)
cat("\nSample LastPurchaseDate:")
print(head(df$LastPurchaseDate,10))

```


```{r Missing values, echo=FALSE}
# 把類別型的欄位文字空格轉換成NA
df <- df %>%
  mutate(
    # across()：對...所有欄位
    # where(is.character)：...所有「文字」欄位
    # ~ na_if(., "")：...執行「na_if(欄位, "")」這個動作
    # na_if(., "") 的意思是：如果值等於 ""，就把它換成 NA
    across(where(is.character), ~ na_if(., ""))
  )


df_col <- names(df)
walk(df_col, function(col_name) { 
 cat("\nMissing Values per Column:")
  cat("\n", col_name)
  na_count <- sum(is.na(df[[col_name]]))
  empty_string_count <- sum(df[[col_name]] == "", na.rm = TRUE) 
  NA_sum <- na_count + empty_string_count
  print(NA_sum) 
  })

# 篩選含有ＮＡ的觀察值
missing_obs_rows <- df %>%
  filter(
    if_any(where(is.character), ~ is.na(.) | . == "") |
    if_any(where(is.numeric), ~ is.na(.))
  )

# missing_obs_rows
datatable(
  head(missing_obs_rows, 10), 
  caption = "缺失列表的前 10 筆觀測值", # 加上標題
  options = list(
    pageLength = 10,  # 設定只顯示 10 行
    searching = FALSE # 隱藏搜尋欄位，讓表格看起來更乾淨
  ),
  rownames = FALSE # 隱藏行號 (可選)
)

cat("\n總共找到", nrow(missing_obs_rows), "筆有問題的觀測值。\n")

vis_miss(df) # 視覺化缺失熱圖
gg_miss_upset(df) # 缺失組合圖 (Upset Plot)
gg_miss_fct(df, SpendingSegment) # 「缺失」是否和「特定族群」有關？
```



```{r Duplicated values, echo=FALSE}
  cat("\nNumber of Duplicated Rows:\n")
  print(sum(duplicated(df)))
```



## Key Observations
### 一、 數值型特徵分析與洞察
#### 1. 年齡 (Age)
玩家平均年齡約為 33.53 歲（標準差 11.99），範圍涵蓋 13 至 54 歲。其分佈呈現明顯的多峰結構，約在 20–25、30–35、45–50 歲出現三個峰值，並帶有輕微右偏。這強烈暗示了遊戲中可能存在多個不同年齡層的玩家族群（如年輕玩家、輕熟齡玩家、中高齡玩家），分群時應著重探索此差異。年齡有 60 筆缺失值，佔整體 2%。

#### 2. 遊戲次數 (SessionCount)
平均遊戲次數為 10.07 次（標準差 3.12），範圍 1 至 22 次。分佈高度尖峰集中於 10–12 次，整體呈對稱狀，近似常態分佈，顯示大部分玩家的遊戲頻率穩定且集中。此特徵無缺失值。

#### 3. 平均遊玩時長 (AverageSessionLength)
平均時長為 20.07 分鐘（標準差 8.59），範圍 5.01 至 34.99 分鐘。分佈近似常態，但略微帶有雙峰特徵，暗示可能存在兩類核心行為模式：一類是追求快速遊玩的玩家，另一類是傾向長時間沉浸的重度玩家。此特徵無缺失值。

#### 4. 內購金額 (InAppPurchaseAmount)
此特徵分佈呈高度右偏，平均值高達 102.58（標準差 454.34），但大多數金額集中在 $0–20，極端長尾由少數高付費玩家（Whales）拉高。範圍為 0 至 4964.45。若要使用基於距離的演算法（如 K-Means），必須考慮對此特徵進行 Log 轉換或 Robust Scaling。此欄位有 136 筆缺失值，佔 4.5%。

#### 5. 首次付費距離安裝時間 (FirstPurchaseDaysAfterInstall)
平均首次付費時間為 15.38 天（標準差 8.95），範圍 0 至 30 天。分佈在安裝後的 25–30 天附近形成高峰，表明多數用戶的付費行為偏向遊戲中後期才發生。缺失值同為 136 筆，與內購金額的缺失值重疊。

### 二、 類別型特徵統計與分群考量
#### 1. 性別 (Gender) 與 裝置類型 (Device)
性別分佈以男性為主（59.9%），女性佔 36.3%，另有 1.9% 為其他，並有 60 筆缺失。裝置類型則由 Android（57.5%） 和 iOS（40.5%） 構成主要群體，同樣有 60 筆缺失。這兩項特徵適合採用 One-Hot 編碼來反映平台與性別偏好差異，但需注意性別中少數類別的處理。

#### 2. 國家 (Country) 與 遊戲類型 (GameGenre)
國家特徵涵蓋全球 27 個類別，以印度佔比最高（8%）。由於類別數過多，若直接 One-Hot 編碼會造成維度爆炸。建議考慮將國家進行分區聚合（例如依大洲分類），或使用目標編碼（Target Encoding）。遊戲類型有 15 種，分佈相對平均，可考慮使用 Label Encoding 或 One-Hot 編碼後搭配降維。

#### 3. 付費等級 (SpendingSegment)
此特徵存在極端的不平衡：低付費者 (Minnow) 佔 84.1%、中付費者 (Dolphin) 佔 13.6%、高付費者 (Whale) 僅佔 2.2%。此欄位極為重要，應作為分群結果的驗證指標，但不宜直接納入分群模型，以避免資訊洩漏。

#### 4. 付款方式 (PaymentMethod)
共有 7 種支付方式，分佈相對平均，可用 One-Hot 編碼來分析不同族群的支付偏好。此欄位有 136 筆缺失。

#### 5. 其他
欄位 LastPurchaseDate 的屬性錯誤，需要轉換為標準的 日期型態。

### 三、 資料品質與缺失值處理策略
#### 1. 資料清洗準備
首先，類別型欄位中以文字型空格表示的缺失值必須統一轉換為標準的 NA 或 NaN 格式，以利後續的數據操作。

#### 2. 關鍵缺失模式洞察
透過缺失熱圖分析，發現有兩組主要的缺失量：60 筆和 136 筆。

136 筆缺失的關鍵關聯性： 內購金額 (InAppPurchaseAmount)、首次付費天數 (FirstPurchaseDaysAfterInstall)、付款方式 (PaymentMethod) 三個欄位的缺失是完全重疊的。這可能源於兩種情況：要麼是未付費玩家的數據（應補 0），要麼是資料在輸出時發生了錯誤。

#### 3. 處理決策與實施策略
基於此處缺失集中在分析的核心付費行為上，本報告採用資料轉換錯誤的假設。為了保證分析的準確性與模型訓練的穩健性，決策如下：

刪除 136 筆紀錄： 由於這 136 筆玩家資料的關鍵付費資訊缺失，可信度低，將直接從數據集中刪除。

中位數、眾數填補 60 筆紀錄： 對於其他 60 筆缺失的 Age、Gender、Device 欄位，由於數量佔比較小，數值型將使用中位數進行填補，類別型將使用眾數進行填補，以保全其餘重要的非付費行為資訊。

### 後續步驟建議
執行數據清洗與缺失值處理：刪除 136 筆數據，並對剩餘 60 筆進行填補。

特徵工程：對 InAppPurchaseAmount 進行 Log 轉換，並對類別型特徵進行合適的編碼與聚合處理。



## Data Preprocessing
```{r 處理數據類型}
# 1. 定義當前日期 (R 的寫法)
current_date <- as.Date("2025-08-24")

df <- df %>%
  filter(!is.na(InAppPurchaseAmount))%>%
  mutate(
    # 2. 將文字轉換為日期
    LastPurchaseDate = as.Date(LastPurchaseDate),
    # 3. 計算日期差異 (R 會回傳 "difftime" 物件)
    #    我們用 as.numeric() 將其轉為天數
    DaysSinceLastPurchase = as.numeric(difftime(current_date, LastPurchaseDate, units = "days"))
  )

```


```{r 定義欄位列表}
# Define feature lists
drop_cols <- c('UserID', 'LastPurchaseDate')  # Drop after engineering

numerical_cols <- c('Age', 'SessionCount', 'AverageSessionLength', 
                    'InAppPurchaseAmount', 'FirstPurchaseDaysAfterInstall', 
                    'DaysSinceLastPurchase')

categorical_cols_label <- c("SpendingSegment") # 低基數種類(有排序)

categorical_cols_onehot <- c('Gender', 'Device', 'PaymentMethod')  # 低基數種類(無排序)

categorical_cols_freq <- c('Country', 'GameGenre')  # 高基數種類
```


```{r 填補缺失}
# 將類別變數缺失補眾數;數值補中位數

# 創眾數函式 (R 沒有內建眾數)
get_mode <- function(v) {
  # 找出非 NA 的唯一值
  uniqv <- unique(v[!is.na(v)])
  # 如果都是 NA，就回傳 NA
  if (length(uniqv) == 0) {
    return(NA)
  }
  # 找出出現最多次的那個值
  uniqv[which.max(tabulate(match(v, uniqv)))]
}

# --- 定義要插補的欄位 ---
numerical_cols_to_impute <- numerical_cols[1:3] # Age, SessionCount, AvgSession
categorical_cols_to_impute <- c(categorical_cols_label, categorical_cols_onehot, categorical_cols_freq)

# --- 使用 `across()` 一次處理所有欄位 ---
df <- df %>%
  mutate(
    # 處理數值欄位：
    # across() 會對 `numerical_cols_to_impute` 中的每一欄
    # 執行 ~ ... 內的 "lambda" 函數
    across(all_of(numerical_cols_to_impute), 
           ~ ifelse(is.na(.), median(., na.rm = TRUE), .)),
    
    # 處理類別欄位：
    across(all_of(categorical_cols_to_impute),
           ~ ifelse(is.na(.), get_mode(.), .))
  )

```


```{r 乾淨數據匯出 for Tableau, echo=FALSE}
df <- df %>%
  select(-UserID, -LastPurchaseDate)
write_csv(df, "/Users/aditi/Documents/移動遊戲玩家分群與商業策略分析/data/processed/data.csv")
```




```{r 標籤編碼（Label Encoding）}
# 1. 「順序規則」
size_levels <- c("Minnow", "Dolphin", "Whale")

# 2. 在 mutate 中合併所有步驟
df_raw <- df %>%
  mutate(
    # 直接建立最終的數字欄位
   num_SpendingSegment = as.numeric(   # 這是「外層」的第二步
      factor(SpendingSegment,        # 這是「內層」的第一步
             levels = size_levels,
             ordered = TRUE)
    )
  )

```



```{r 獨熱編碼 (One-Hot Encoding)}

df_raw <- dummy_cols(
  df_raw,
  select_columns = categorical_cols_onehot, # 直接把整個向量傳給它
  remove_selected_columns = TRUE,  # 刪除原始的 "city" 和 "payment_method" 欄位
  # 【關鍵修正】只建立 K-1 個虛擬變數
  remove_first_dummy = TRUE
)


```



```{r 頻率編碼 (Frequency Encoding)}

# 3. 開始 for 迴圈
for (col_name in categorical_cols_freq) {
  
  # 3a. 動態計算每個欄位的頻率
  # 我們使用 paste0() 來動態命名新欄位 (例如 "city_frequency", "payment_method_frequency")
  # 我們使用 .data[[col_name]] 讓 dplyr 知道 col_name 是一個變數
  counts <- df_raw %>%
    count(.data[[col_name]], name = paste0(col_name, "_frequency"))
  
  print(paste("--- 正在處理:", col_name, "---"))
  print(counts)
  
  # 3b. 將計算出的頻率表合併回 df_freq_encoded
  # R 會自動偵測同名欄位 (col_name) 來進行合併
  df_raw <- df_raw %>%
    left_join(counts, by = col_name)
}


```


```{r df_raw preview-head, echo=FALSE}
# 確保只顯示前 10 行
datatable(
  head(df_raw, 10), 
  caption = "數據數值化後的 10 筆觀測值",   # 標題
  options = list(
    pageLength = 10,   # 設定只顯示 10 行
    searching = FALSE  # 隱藏搜尋欄位，讓表格看起來更乾淨
  ),
  rownames = FALSE # 隱藏行號 (可選)
)
```


```{r 數據標準化, results = 'hide'}
# 標準化
df_clean <- df_raw %>%
  mutate(
    # 修正後的寫法：使用 as.vector() 剝離矩陣屬性
    across(
      where(is.numeric), 
      ~ as.vector(scale(.x)) # <-- 關鍵：確保將結果轉回向量
    )
  )

describe(df_clean) # 再次確認已標準化
```


```{r 輸出完整數值型態數據表, echo=FALSE}
df_clean <- df_clean %>%
  select(-Country, -GameGenre, -SpendingSegment)

write_csv(df_clean, "/Users/aditi/Documents/移動遊戲玩家分群與商業策略分析/data/raw/clean_df.csv")

df_new <- df_clean %>%
  select(-num_SpendingSegment)

```



## Key Observations
### 一、 數據集清洗與特徵工程
為建立一個乾淨、標準化的數據集，我們執行了以下關鍵前處理步驟：

#### 1.數據類型轉換：
LastPurchaseDate 成功轉換為日期型態。
類別型欄位中的文字空格轉換為標準缺失值。

#### 2.缺失值處理：
刪除 136 筆付費相關資訊（如 InAppPurchaseAmount）缺失的紀錄，以專注於付費玩家的分析。
對剩餘 60 筆缺失值，使用中位數/眾數進行填補。

#### 3.欄位數值化與標準化：
InAppPurchaseAmount 進行了 $log(1+x)$ 轉換以處理高度右偏問題。

#### 4.類別編碼： Gender、Device、PaymentMethod 採用 One-Hot 編碼；SpendingSegment 採用標籤編碼；Country 和 GameGenre 採用頻率編碼。
所有數值型特徵皆完成了標準化處理。


## 卡方/費雪檢定
```{r 卡方檢定, echo=FALSE}
###### 這裡用的是還沒經過數值化的數據
# Gender 
chi_sq_resultG <- chisq.test(table(df$Gender, df$SpendingSegment))
print("--- 卡方檢定結果 Gender VS. SpendingSegment---")
print(chi_sq_resultG)

# Country
chi_sq_resultC <- chisq.test(table(df$Country, df$SpendingSegment))
print("--- 卡方檢定結果 Country VS. SpendingSegment---")
print(chi_sq_resultC)

# Device
chi_sq_resultD <- chisq.test(table(df$Device, df$SpendingSegment))
print("--- 卡方檢定結果 Device VS. SpendingSegment---")
print(chi_sq_resultD)

# GameGenre
chi_sq_resultGG <- chisq.test(table(df$GameGenre, df$SpendingSegment))
print("--- 卡方檢定結果 GameGenre VS. SpendingSegment---")
print(chi_sq_resultGG)

# PaymentMethod
chi_sq_resultP <- chisq.test(table(df$PaymentMethod, df$SpendingSegment))
print("--- 卡方檢定結果 PaymentMethod VS. SpendingSegment---")
print(chi_sq_resultP)


Gexp_5 <- sum(chi_sq_resultG$expected < 5)
cat("Gender 交叉細格的期望次數低於5的數量：", Gexp_5, "\n")

Cexp_5 <- sum(chi_sq_resultC$expected < 5)
cat("Country 交叉細格的期望次數低於5的數量：", Cexp_5, "\n")

Dexp_5 <- sum(chi_sq_resultD$expected < 5)
cat("Device 交叉細格的期望次數低於5的數量：", Dexp_5, "\n")

GGexp_5 <- sum(chi_sq_resultGG$expected < 5)
cat("GameGenre 交叉細格的期望次數低於5的數量：", GGexp_5, "\n")

Pexp_5 <- sum(chi_sq_resultP$expected < 5)
cat("PaymentMethod 交叉細格的期望次數低於5的數量：", Pexp_5, "\n")


# Gender 
fisher_resultG <- fisher.test(table(df$Gender, df$SpendingSegment), 
            simulate.p.value = TRUE, 
            B = 10000)
print("--- 費雪檢定結果 Gender VS. SpendingSegment ---")
print(fisher_resultG)

# Country
fisher_resultC <- fisher.test(table(df$Country, df$SpendingSegment), 
            simulate.p.value = TRUE, 
            B = 10000)
print("--- 費雪檢定結果 Country VS. SpendingSegment---")
print(fisher_resultC)

# GameGenre
fisher_resultGG <- fisher.test(table(df$GameGenre, df$SpendingSegment), 
            simulate.p.value = TRUE, 
            B = 10000)
print("--- 卡方檢定結果 GameGenre VS. SpendingSegment---")
print(fisher_resultGG)
```

本分析旨在檢測五個核心類別變數（Gender, Country, Device, GameGenre, PaymentMethod）與目標變數「付費層級 (SpendingSegment)」之間的統計關聯。由於部分交叉細格的期望次數過低，檢測方法轉為更嚴謹的 Fisher 精確檢定。

檢測結果顯示，所有變數的 P 值（介於 0.1889 至 0.6159 之間）均遠高於 0.05 的顯著水準。這強烈表明：在統計學上，我們無法拒絕這些變數彼此獨立的虛無假設。

結論： 用戶的性別、國籍、裝置類型、遊戲偏好和付款方式，與其成為高價值玩家的傾向是彼此獨立、不具有顯著關聯性的。這些基本資訊在您的預測模型中，將被視為弱特徵。因此，分析的戰略重點必須完全轉向反映用戶參與意圖和價值的行為特徵（如 SessionCount 和 DaysSinceLastPurchase）。









## 相關性分析
```{r 相關性矩陣 plot, fig.width=12, fig.height=12, echo=FALSE}

# 相關係數矩陣
cor_matrix <- cor(df_new, 
                  method = "spearman")

# 視覺化
corrplot(
  cor_matrix,
  # --- 核心參數 (Core Functionality) ---
  method = "color",                     # 核心：使用顏色方塊 (Equivalent to sns.heatmap)
  type = "full",                        # 顯示完整矩陣
  
  # --- 疊加係數 (annot=True, fmt='.2f') ---
  addCoef.col = "black",                # 在方塊上疊加相關係數的數值
  number.cex = 0.7,                     # 係數字體大小 (對應 annot_kws={"size":10})
  
  # --- 顏色和細節 (cmap="YlGnBu", linewidths=0.5) ---
  col = COL2("RdBu", 200),            # 應用 YlGnBu 顏色規模
  tl.col = "black",                     # 標籤顏色
  tl.cex = 0.8,                         # 調整標籤大小
  
  # --- 可選的佈局參數 ---
  diag = FALSE,                         # 隱藏對角線 (因為自己和自己相關性是 1)
  order = "original",                   # 按照原始欄位順序排列
  mar = c(0, 0, 0, 0)                   # 調整邊界 (類似 Matplotlib 的 figure/axes setup)
)

```
經斯皮爾曼等級相關係數矩陣（Spearman’s Rank Correlation Matrix）的檢測，本研究發現所有數值預測變數之間的關聯程度極為鬆散。
具體而言，任何兩變數之間的相關係數絕對值 $|r|$ 均未超過 0.20。
此結果清晰地描繪出數據集中的特徵彼此間高度獨立，共同變異數極為稀疏。





## 差異性分析
```{r 常態性檢測, echo=FALSE}
new_col <- names(df_new)
walk(new_col, function(col_name) {
  data_vector <- df_new[[col_name]]
  skew_value <- skew(data_vector)
  
  # 1. 建立動態標題 (含偏態數值)
      plot_title <- paste("Q-Q Plot for:", col_name, " (Skew:", round(skew_value, 3), ")")
      
      # 2. 繪製 Q-Q 點和常態參考線
      qqnorm(data_vector, main = plot_title)
      qqline(data_vector, col = "red", lwd = 2)
      
  
  # 判斷是否超過中度偏態門檻 (>= 0.5)
  if (abs(skew_value) >= 0.5) {
      cat("\n偏態！", col_name,  "\n")
      print(round(skew_value, 3))
  } else {
      cat("\n 常態好棒棒:",  col_name, "\n")      
      print(round(skew_value, 3))}
  })


```
常態沒通過，用無母數方法來進行檢測



## Wilcoxon Test
```{r wilcox.test, echo=FALSE}
# 這裡要用df做分析（不接受one-hot後的）
# 對 InAppPurchaseAmount
wilcox_Device_Amount <- wilcox.test(InAppPurchaseAmount ~ Device, data = df)
print("--- Wilcoxon 檢定結果 InAppPurchaseAmount VS. Device ---")
print(wilcox_Device_Amount)

# 對 DaysSinceLastPurchase
wilcox_Device_DaysSinceLast <- wilcox.test(DaysSinceLastPurchase ~ Device, data = df)
print("--- Wilcoxon 檢定結果 DaysSinceLastPurchase VS. Device ---")
print(wilcox_Device_DaysSinceLast)

# AverageSessionLength
wilcox_Device_SessionLength <- wilcox.test(AverageSessionLength ~ Device, data = df)
print("--- Wilcoxon 檢定結果 AverageSessionLength VS. Device---")
print(wilcox_Device_SessionLength)

```

經由 Wilcoxon 等級和檢定 (Wilcoxon Rank-Sum Test) 評估，我們對裝置平台（Device）與核心玩家指標之間的差異性進行了深入檢測。

分析結果顯示，無論是在付費金額（InAppPurchaseAmount）、平均遊玩時長（AverageSessionLength）還是流失傾向（DaysSinceLastPurchase）上，iOS 用戶群體與 Android 用戶群體之間的中位數差異均未達到統計上的顯著水準。
具體而言，兩項檢測的 P 值均大於 0.05 （付費金額 P 值為 0.06789，平均遊玩時長 P 值為0.3532，流失傾向 P 值為 0.3366）。

最終結論： 這些發現強烈表明，用戶使用的裝置類型與其核心的金錢價值、遊玩時長及活躍程度在統計上彼此獨立，無關聯。
因此，在構建預測模型時，應將「裝置」變數視為弱預測因子，並將分析重心轉向更具區分力的行為特徵。




## Kruskal Test
```{r kruskal.test, echo=FALSE}

# InAppPurchaseAmount
Amount_kruskal_Gender <- kruskal.test(InAppPurchaseAmount ~ Gender, data = df)
print("--- Kruskal-Wallis 檢定結果 InAppPurchaseAmount VS. Gender---")
print(Amount_kruskal_Gender)

Amount_kruskal_Country <- kruskal.test(InAppPurchaseAmount ~ Country, data = df)
print("--- Kruskal-Wallis 檢定結果 InAppPurchaseAmount VS. Country---")
print(Amount_kruskal_Country)

Amount_kruskal_GameGenre <- kruskal.test(InAppPurchaseAmount ~ GameGenre, data = df)
print("--- Kruskal-Wallis 檢定結果 InAppPurchaseAmount VS. GameGenre---")
print(Amount_kruskal_GameGenre )

Amount_kruskal_PaymentMethod <- kruskal.test(InAppPurchaseAmount ~ PaymentMethod, data = df)
print("--- Kruskal-Wallis 檢定結果 InAppPurchaseAmount VS. PaymentMethod---")
print(Amount_kruskal_PaymentMethod)


# AverageSessionLength
ASL_kruskal_Gender <- kruskal.test(AverageSessionLength ~ Gender, data = df)
print("--- Kruskal-Wallis 檢定結果 AverageSessionLength VS. Gender ---")
print(ASL_kruskal_Gender)

ASL_kruskal_Country <- kruskal.test(AverageSessionLength ~ Country, data = df)
print("--- Kruskal-Wallis 檢定結果 AverageSessionLength VS. Country---")
print(ASL_kruskal_Country)

ASL_kruskal_GameGenre <- kruskal.test(AverageSessionLength ~ GameGenre, data = df)
print("--- Kruskal-Wallis 檢定結果 AverageSessionLength VS. GameGenre ---")
print(ASL_kruskal_GameGenre)

ASL_kruskal_PaymentMethod <- kruskal.test(AverageSessionLength ~ PaymentMethod, data = df)
print("--- Kruskal-Wallis 檢定結果 AverageSessionLength VS. PaymentMethod---")
print(ASL_kruskal_PaymentMethod)

# DaysSinceLastPurchase
Days_kruskal_Gender <- kruskal.test(DaysSinceLastPurchase ~ Gender, data = df)
print("--- Kruskal-Wallis 檢定結果 DaysSinceLastPurchase VS. Gender---")
print(Days_kruskal_Gender)

Days_kruskal_Country <- kruskal.test(DaysSinceLastPurchase ~ Country, data = df)
print("--- Kruskal-Wallis 檢定結果 DaysSinceLastPurchase VS. Country---")
print(Days_kruskal_Country)

Days_kruskal_GameGenre <- kruskal.test(DaysSinceLastPurchase ~ GameGenre, data = df)
print("--- Kruskal-Wallis 檢定結果 DaysSinceLastPurchase VS. GameGenre---")
print(Days_kruskal_GameGenre)

Days_kruskal_PaymentMethod <- kruskal.test(DaysSinceLastPurchase ~ PaymentMethod, data = df)
print("--- Kruskal-Wallis 檢定結果 DaysSinceLastPurchase VS. PaymentMethod---")
print(Days_kruskal_PaymentMethod)
 
```

經由 Kruskal-Wallis 檢定評估，所有核心行為指標（付費金額、平均會話時長、流失天數）在主要類別群體中的分佈皆未能達到統計顯著水準（所有 P 值均大於 $\alpha = 0.05$）。

1. 付費金額 (InAppPurchaseAmount) 的分析與所有類別的關聯性： 
Gender ($P = 0.6945$)、Country ($P = 0.1025$)、GameGenre ($P = 0.7243$) 和 PaymentMethod ($P = 0.7644$) 對於玩家的付費金額中位數均不具有統計上的顯著影響。
洞察： 即使考慮了數據的偏態，玩家所屬的國家、性別或喜歡的遊戲類型，與他們最終的付費價值無關聯。

2. 遊戲時長與流失傾向 (Engagement & Churn Propensity) 的分析AverageSessionLength： 
在所有類別群體中的 P 值均高於 $0.45$，表明平均遊戲時長在不同性別、國家、遊戲類型或支付方式的群體中沒有顯著差異。
DaysSinceLastPurchase： 所有檢定的 P 值均高於 $0.28$，表明玩家的流失傾向與其人口統計學特徵或偏好彼此獨立。

最終結論：模型策略的必要轉向綜合上述檢定結果，我們強烈確認了先前的洞察：
用戶的基本類別型特徵（人口統計與偏好）對其核心行為指標的影響極為微弱或不存在。





## 最終分析總結與策略確認
### 核心發現 (Consolidated Findings)綜合所有檢定結果:
#### 1. 人口統計學的獨立性 (Independence):
經 Fisher's 和 Kruskal-Wallis 檢定，所有基本類別型特徵（Gender, Country, Device, GameGenre, PaymentMethod）與用戶的核心行為指標（付費金額、時長、流失傾向）均呈統計獨立。

#### 2.結論： 
這些靜態特徵對用戶的付費價值不具備預測能力。
結構性偏態與鬆散相關性 (Structural Skew):InAppPurchaseAmount 等欄位經 Log 轉換後仍具偏態，證實了數據的複雜性和零值膨脹問題。數值特徵之間相關性極低（$|r| < 0.20$），這排除了多重共線性風險，並證實了 Random Forest 模型是最佳選擇。

#### 3.付費流失的定義：
刪除了 136 筆邏輯衝突的數據，確保了後續分析是基於一個邏輯一致的「付費玩家群體」和「可信的 Minnow 群體」。

### 最終結論：模型策略的必要轉向
本分析的結論是決定性的：必須將預測模型的重心，完全且唯一地轉向那些能反映玩家「投入程度」與「行為意圖」的數值特徵上。 任何試圖透過基本人口統計資料來區分高價值玩家的努力，都缺乏統計學依據。


# 隨機森林分析
```{r}
df_clean <- df_clean %>%
  mutate(
    # 將 SpendingSegment 欄位從 character/numeric 強制轉換為 factor
    num_SpendingSegment = as.factor(num_SpendingSegment)
  )
```

```{r 分割數據}
# 設置隨機種子 (確保每次分割結果都一樣，方便重現)
set.seed(42) 

# 建立分割結構：80% 訓練集，20% 測試集
# 【關鍵】strata = SpendingSegment 確保 Whale 和 Minnow 的比例不被打亂
data_split <- initial_split(df_clean, 
                            prop = 0.8,           
                            strata = num_SpendingSegment)
```


```{r}
# 提取訓練集 (Training Set)
df_train <- training(data_split) 

# 提取測試集 (Test Set)
df_test <- testing(data_split)   

cat("數據分割完成：\n")
cat("訓練集大小 (Rows):", nrow(df_train), "\n")
cat("測試集大小 (Rows):", nrow(df_test), "\n")
```


# 目標： 找出付費層級的特徵
```{r 定義模型規格}
rf_model_spec <- 
  rand_forest(
    trees = 500 # 總共建立 500 棵樹，確保結果穩定
  ) %>%
  set_mode("classification") %>%      # 指定這是分類任務 (預測 Whale/Dolphin/Minnow)
  set_engine("ranger", 
             seed = 42, 
             importance = "impurity") # 啟用特徵重要性計算

print(rf_model_spec)

```

```{r 定義工作流程和訓練}
# 建立模型公式：使用所有特徵 (X) 來預測 SpendingSegment (Y)
# ~ . - InAppPurchaseAmount_log 的意思是：使用所有欄位 (.), 排除 (-) InAppPurchaseAmount_log
model_formula <- num_SpendingSegment ~ . - InAppPurchaseAmount

# 建立工作流 (Workflow)
rf_workflow <- workflow() %>%
  add_formula(model_formula) %>%
  add_model(rf_model_spec)

# 在訓練集上訓練模型 (核心計算步驟)
cat("開始訓練 Random Forest...\n")
rf_fit <- fit(rf_workflow, data = df_train)

cat("\n✅ 模型訓練完成！\n")
```

```{r 使用測試集評估模型} 
# 在測試集上生成預測結果
rf_test_results <- predict(rf_fit, new_data = df_test, type = "class") %>%
  bind_cols(df_test %>% select(num_SpendingSegment)) # 綁定真實標籤

# 計算準確率和混淆矩陣
rf_metrics <- metrics(rf_test_results, truth = num_SpendingSegment, estimate = .pred_class)
print("--- 模型性能指標 ---")
print(rf_metrics)
```

```{r 提取核心業務洞察}
# 提取模型中的特徵重要性 (ranger 引擎自動計算)
rf_feature_importance <- extract_fit_engine(rf_fit) %>%
  ranger::importance() %>%
  enframe(name = "Feature", value = "Importance") %>%
  arrange(desc(Importance))

cat("\n--- 特徵重要性報告 (前 10 名) ---")
print(head(rf_feature_importance, 10))
```

```{r}
# 假設 rf_feature_importance 是您在 SOP 步驟 4 中提取的表格

importance_plot <- rf_feature_importance %>%
  # 篩選出 top 10 的特徵 (如果表格超過 10 個)
  head(10) %>%
  
  # 【關鍵步驟】: 按 Importance 分數排序，並轉為因子 (Factor)
  mutate(Feature = fct_reorder(Feature, Importance)) %>%
  
  ggplot(aes(x = Importance, y = Feature, fill = Importance)) +
  geom_col() +
  labs(
    title = "核心預測因子重要性排名 (Random Forest)",
    subtitle = "分數越高，對預測付費層級的貢獻越大。",
    x = "重要性分數 (Gini Index/Impurity)",
    y = NULL # 隱藏 Y 軸標籤 (因為 Feature 名稱已經是標籤)
  ) +
  theme_minimal()
  
print(importance_plot)
```

```{r}
# 假設 rf_conf_mat 是您在 SOP 步驟 3 中計算出的混淆矩陣物件

# 1. 計算混淆矩陣
rf_conf_mat <- rf_test_results %>%
  conf_mat(truth = num_SpendingSegment, estimate = .pred_class)

# 2. 【關鍵】繪製混淆矩陣熱圖
#    這會顯示模型在每個類別上正確分類和錯誤分類的數量/比例
conf_mat_plot <- autoplot(rf_conf_mat, type = "heatmap") +
  labs(
    title = "模型分類效能 (測試集)",
    subtitle = "對角線顯示正確預測的比例",
    caption = paste("整體準確率:", round(rf_metrics$.estimate[1], 3))
  ) +
  theme(plot.title = element_text(hjust = 0.5))

print(conf_mat_plot)
```


## 總結與戰略建議 (Conclusion and Strategic Recommendation)

經由 Kruskal-Wallis 檢定、特徵重要性分析及魯棒模型（Random Forest）的綜合評估，本專案已成功將複雜且具備高度偏態的數據集，轉化為具備高預測能力的分析資產。

### 核心結論確立：

#### 人口統計學的無效性： 
統計檢定堅實地證明，用戶的基礎人口特徵（性別、國籍、裝置等）與其付費價值是彼此獨立、無關聯的。這排除了傳統的廣告目標投放策略。

#### 行為指標的決定性： 
模型訓練結果顯示，玩家的付費價值和流失風險的預測力，完全集中於行為特徵。Random Forest 模型強烈指明，**「內容粘性」（AverageSessionLength）和「流失傾向」（DaysSinceLastPurchase）**是區分高價值用戶的決定性因素。

### 最終戰略建議 (Actionable Recommendation)
基於此分析，我們建議將營運資源從無效的人口統計區隔中撤出，並集中於行為數據的優化：

#### 優化用戶留存： 
優先開發能延長玩家單次會話時長 (AverageSessionLength) 的內容，以直接提高用戶的終身價值 (LTV)。

#### 精準召回： 
利用 DaysSinceLastPurchase 建立自動化預警機制，將行銷召回的預算精準投放給那些處於高流失風險區間的玩家，以獲得最大的投資回報率 (ROI)。

