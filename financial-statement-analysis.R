#Data
revenue <- c(14574.49, 7606.46, 8611.41, 9175.41, 8058.65, 8105.44, 11496.28, 9766.09, 10305.32, 14379.96, 10713.97, 15433.50)
expenses <- c(12051.82, 5695.07, 12319.20, 12089.72, 8658.57, 840.20, 3285.73, 5821.12, 6976.93, 16618.61, 10054.37, 3803.96)


#Profit each month

profit <- revenue - expenses
profit

#Profit after tax for each month (30% tax rate)

tax <- round(profit*0.3,2)
tax

profit_after_tax <-  profit - tax
profit_after_tax

#Profit margin for each month (profit after tax divided by revenue)


profit_margin <- round(profit_after_tax / revenue,2)*100
profit_margin 


months <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
profit_after_tax_mean <- round(mean(profit_after_tax),2)
profit_after_tax_mean


#Good months - where profit after tax was greater than yearly mean

good_months <- c()

for (i in 1:length(revenue)){
  if (profit_after_tax[i] > profit_after_tax_mean){
    good_months <- append(good_months, months[i])
  }
}
good_months #Could do this instead: good_months <- profit_after_tax > mean_pat


#Bad months - where profit after tax was else than yearly mean

bad_months  <- c()
for (i in 1:length(revenue)){
  if (profit_after_tax[i] < profit_after_tax_mean){
    bad_months <- append(bad_months, months[i])
  }
}
bad_months


#Best month - where the profit after tax was max for the year

best_profit <- max(profit_after_tax)
best_index <- match(best_profit, profit_after_tax)
best_index 

best_month <- c(months[best_index])
best_month 

#Could do this: best_month <- profit_after_tax == max(profit_after_tax)
#but we want the actual month to be outputted


#Worst month - where the profit after tax was min for the year

worst_profit <- min(profit_after_tax)
worst_index <- match(worst_profit, profit_after_tax)
worst_index 

worst_month <- c(months[worst_index])
worst_month

#PREPARATION FOR OUTPUT 
#Units of thousands

revenue1000 <- round(revenue/1000)
revenue1000

expenses1000 <- round(expenses/1000)
expenses1000

profit1000 <- round(profit/1000)
profit1000

profit_after_tax_1000 <- round(profit_after_tax/1000)
profit_after_tax_1000

#FINAL OUTPUT

#FINANCIAL STATEMENT SUMMARY

m <- rbind(
revenue1000,
expenses1000,
profit1000,
profit_after_tax_1000,
profit_margin
)

m

print("Good months")
good_months

print("Bad months")
bad_months

print ("Best month")
best_month
max(profit_after_tax)

print ("Worst month")
worst_month
min(profit_after_tax)




