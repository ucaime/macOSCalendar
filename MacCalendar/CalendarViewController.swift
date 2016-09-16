//
//  CalendarViewController.swift
//  MacCalendar
//
//  Created by bugcode on 16/7/16.
//  Copyright © 2016年 bugcode. All rights reserved.
//

import Cocoa

class CalendarViewController: NSWindowController, NSTextFieldDelegate {
    
    
    // MARK: - Outlets define

    
    // 年和月上的箭头
    @IBOutlet weak var nextYearBtn: NSButton!
    @IBOutlet weak var lastYearBtn: NSButton!
    @IBOutlet weak var nextMonthBtn: NSButton!
    @IBOutlet weak var lastMonthBtn: NSButton!
    
    // 顶部三个label
    @IBOutlet weak var yearText: NSTextField!
    @IBOutlet weak var monthText: NSTextField!
    
    // 右侧显示区
    @IBOutlet weak var dateDetailLabel: NSTextField!
    @IBOutlet weak var dayLabel: NSTextField!

    @IBOutlet weak var lunarDateLabel: NSTextField!
    @IBOutlet weak var lunarYearLabel: NSTextField!
    
    // 日历类实例
    var mCalendar: LunarCalendarUtils = LunarCalendarUtils()
    var mCurMonth: Int = 0
    var mCurDay: Int = 0
    var mCurYear: Int = 0
    // 每个显示日期的单元格
    var cellBtns = [CalendarCellView]()
    var lastRowNum:Int = 0
    
    override var windowNibName: String?{
        return "CalendarViewController"
    }
    
    // MARK: Button handler
    @IBAction func lastMonthHandler(_ sender: NSButton) {
        var lastMonth = mCurMonth - 1
        if lastMonth < 1 {
            lastMonth = 12
            mCurYear -= 1
        }
        setDate(year: mCurYear, month: lastMonth)
    }
    
    @IBAction func nextMonthHandler(_ sender: NSButton) {
        var nextMonth = mCurMonth + 1
        if nextMonth > 12 {
            nextMonth = 1
            mCurYear += 1
        }
        setDate(year: mCurYear, month: nextMonth)
    }

    @IBAction func nextYearHandler(_ sender: NSButton) {
        let nextYear = mCurYear + 1
        setDate(year: nextYear, month: mCurMonth)
    }
    
    @IBAction func lastYearHandler(_ sender: NSButton) {
        let lastYear = mCurYear - 1
        setDate(year: lastYear, month: mCurMonth)
    }
    
    // 响应NSTextField的回车事件
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if 	commandSelector == #selector(insertNewline(_:)) {
            print("text = \(textView.string!)")
            return true
        }
        
        return false
    }
    
    
    func showMonthPanel() {
        
        let year = mCurYear
        let month = mCurMonth
        
        let utils = CalendarUtils.sharedInstance
        
        let mi = mCalendar.getMonthInfo(month: mCurMonth)
        
        // 根据日期字符串获取当前月共有多少天
        let monthDays = mi.mInfo.days
        
        // 显示上方二个区域的年份与月份信息
        yearText.stringValue = String(year)
        monthText.stringValue = String(mCurMonth)
        // 上个月有多少天
        var lastMonthDays = 0
        if month == 1 {
            lastMonthDays = utils.getDaysBy(year: year - 1, month: 12)
        } else {
            lastMonthDays = utils.getDaysBy(year: year, month: month - 1)
        }
        
        
        // 本月第一天与最后一天是周几
        let weekDayOf1stDay = mi.mInfo.weekOf1stDay
        let dayInfo = mi.getDayInfo(day: monthDays - 1)
        let weekDayOfLastDay = dayInfo.week

        
        print("dateString = \(year)-\(month) weekOf1stDay = \(weekDayOf1stDay) weekOfLastDay = \(weekDayOfLastDay) monthDays = \(monthDays) ")
        
        // 把空余不的cell行不显示，非本月天置灰
        for (index, btn) in cellBtns.enumerated() {
            
            btn.isEnabled = true
            btn.isTransparent = false
            
            if index < weekDayOf1stDay || index >= monthDays + weekDayOf1stDay {
                let curRowNum = Int((btn.cellID - 1) / 7) + 1
                // 最后一行空出来
                if index >= monthDays + weekDayOf1stDay && curRowNum > lastRowNum {
                    btn.isTransparent = true
                }else{
                    btn.isEnabled = false
                }
                // 处理前后二个月的显示日期 (灰置部分)
                if index < weekDayOf1stDay {
                    
                    let day = lastMonthDays - weekDayOf1stDay + index + 1
                    // 当前的农历日期
                    let mi = mCalendar.getMonthInfo(month: mCurMonth - 1)
                    let dayInfo = mi.getDayInfo(day: day)
                    let chnMonthInfo = mCalendar.getChnMonthInfo(month: dayInfo.mmonth)
                    
                    var lunarDayName = CalendarConstant.nameOfChnMonth[chnMonthInfo.mInfo.mname - 1] + "月"
                    if chnMonthInfo.isLeapMonth() {
                        lunarDayName = "闰" + lunarDayName
                    }
                    
                    let dayName = CalendarConstant.nameOfChnDay[dayInfo.mdayNo]

                    
                    btn.setString(topText: "\(day)", topColor: .black, bottomText: dayName, bottomColor: NSColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1))
                }else {
                    let day = index - monthDays - weekDayOf1stDay + 1
                    // 当前的农历日期
                    let mi = mCalendar.getMonthInfo(month: mCurMonth + 1)
                    let dayInfo = mi.getDayInfo(day: day)
                    
                    var lunarDayName = ""
                    if dayInfo.mdayNo == 0 {
                        let chnMonthInfo = mCalendar.getChnMonthInfo(month: dayInfo.mmonth)
                        if chnMonthInfo.isLeapMonth() {
                            lunarDayName += "闰"
                        }
                        
                        lunarDayName += CalendarConstant.nameOfChnMonth[chnMonthInfo.mInfo.mname - 1]
                        lunarDayName += (chnMonthInfo.mInfo.mdays == CalendarConstant.CHINESE_L_MONTH_DAYS) ? "月大" : "月小"
                    } else {
                        lunarDayName += CalendarConstant.nameOfChnDay[dayInfo.mdayNo]
                    }

                    
                    btn.setString(topText: "\(day)", topColor: .black, bottomText: lunarDayName, bottomColor: NSColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1))
                }
                
            } else {
                if index == monthDays + weekDayOf1stDay - 1 {
                    // 当前cell在第几行
                    lastRowNum = Int((btn.cellID - 1) / 7) + 1
                }
                
                let day = index - weekDayOf1stDay + 1
                //btn.title = "\(index - weekDayOf1stDay + 1)"
                
                let dayInfo = mi.getDayInfo(day: day)
                var lunarDayName = ""
                if dayInfo.mdayNo == 0 {
                    let chnMonthInfo = mCalendar.getChnMonthInfo(month: dayInfo.mmonth)
                    if chnMonthInfo.isLeapMonth() {
                        lunarDayName += "闰"
                    }
                    
                    lunarDayName += CalendarConstant.nameOfChnMonth[chnMonthInfo.mInfo.mname - 1]
                    lunarDayName += (chnMonthInfo.mInfo.mdays == CalendarConstant.CHINESE_L_MONTH_DAYS) ? "月大" : "月小"
                } else {
                    lunarDayName += CalendarConstant.nameOfChnDay[dayInfo.mdayNo]
                }
                
                btn.setString(topText: "\(day)", topColor: .black, bottomText: lunarDayName, bottomColor: NSColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1))
                
                
                // 处理周六日的日期颜色
                if index % 7 == 6 || index % 7 == 0 {
                    btn.setString(topText: "\(day)", topColor: .red, bottomText: lunarDayName, bottomColor: .red)
                }
            }
            
        }

    }
    
    // 显示日历面板右侧详情
    func showRightDetailInfo(){
        // 获取每月第一天是周几
        
        let curWeekDay = CalendarUtils.sharedInstance.getWeekDayBy(mCurYear, month: mCurMonth, day: mCurDay)
        dateDetailLabel.stringValue = String(mCurYear) + "年" + String(mCurMonth) + "月" + String(mCurDay) + "日 星期" + CalendarConstant.WEEK_NAME_OF_CHINESE[curWeekDay]
        dayLabel.stringValue = String(mCurDay)
        
        showLunar()
    }
    
    
    // 根据xib中的identifier获取对应的cell
    func getButtonByIdentifier(_ id:String) -> NSView? {
        for subView in (self.window?.contentView?.subviews[0].subviews)! {
            if subView.identifier == id {
                return subView
            }
        }
        return nil
    }
    
    
    func dateButtonHandler(_ sender:NSButton){
        print("Press Button is \(sender.identifier)")
    }
    
    
    func showLunar() {
        var stems: Int = 0, branches: Int = 0, sbMonth:Int = 0, sbDay:Int = 0
        let year = mCalendar.getCurrentYear()
        mCalendar.getSpringBeginDay(month: &sbMonth, day: &sbDay)
        CalendarUtils.sharedInstance.calculateStemsBranches(year: (mCurMonth >= sbMonth) ? year : year - 1, stems: &stems, branches: &branches)
        
        // 当前的农历年份
        let lunarStr = "农历 \(CalendarConstant.HEAVENLY_STEMS_NAME[stems - 1])\(CalendarConstant.EARTHY_BRANCHES_NAME[branches - 1])【\(CalendarConstant.CHINESE_ZODIC_NAME[branches - 1])年】"
        lunarYearLabel.stringValue = lunarStr
        
        // 当前的农历日期
        let mi = mCalendar.getMonthInfo(month: mCurMonth)
        let dayInfo = mi.getDayInfo(day: mCurDay)
        let chnMonthInfo = mCalendar.getChnMonthInfo(month: dayInfo.mmonth)
        
        var lunarDayName = CalendarConstant.nameOfChnMonth[chnMonthInfo.mInfo.mname - 1] + "月"
        if chnMonthInfo.isLeapMonth() {
                lunarDayName = "闰" + lunarDayName
        }

        let dayName = CalendarConstant.nameOfChnDay[dayInfo.mdayNo]

        lunarDateLabel.stringValue = lunarDayName + dayName
    }
    

    
    
    func setCurrenMonth(month: Int) {
        if month >= 1 && month <= CalendarConstant.MONTHES_FOR_YEAR {
            mCurMonth = month
            //showDateCells()
            showMonthPanel()
        }
    }
    
    func setDate(year: Int, month: Int) {
        mCurYear = year
        
        if mCalendar.setGeriYear(year: year) {
            setCurrenMonth(month: month)
        }
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        // 将所有cell加入数组管理，并加入回调逻辑
        for i in 0 ... 5 {
            for j in 0 ... 6 {
                let intValue = (i * 7 + j + 1)
                let id = "cell\(intValue)"
                if let btn = self.getButtonByIdentifier(id) {
                    let cellBtn = btn as! CalendarCellView
                    cellBtn.target = self
                    cellBtn.action = #selector(CalendarViewController.dateButtonHandler(_:))
                    cellBtn.cellID = intValue
                    cellBtns.append(cellBtn)
                }
            }
        }
        
        for (index, btn) in cellBtns.enumerated() {
            print("cellbtns index = \(index) btn.action = \(btn.action) btn.intValue = \(btn.cellID)")
        }
        
        
        // 加载完窗口显示默认
        // self.showDefaultDate()
        let date = CalendarUtils.sharedInstance.getDateStringOfToday()
        let dateTupple = CalendarUtils.sharedInstance.getYMDTuppleBy(date)
        mCurDay = dateTupple.day

        mCurYear = dateTupple.year
        
        if mCalendar.setGeriYear(year: mCurYear) {
            setCurrenMonth(month: dateTupple.month)
            showRightDetailInfo()
        }
    }
    
}
