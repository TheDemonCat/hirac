
&HTTPMethod("GET")
Функция list() Экспорт

	ТипОбъектов = Неопределено;

	Если ТипЗнч(ЗначенияМаршрута) = Тип("Соответствие") Тогда
		ТипОбъектов = ЗначенияМаршрута.Получить("type");
	КонецЕсли;

	Результат = ПолучениеСчетчиков.Список(ТипОбъектов);

	Возврат Содержимое(Результат);

КонецФункции // list()

&HTTPMethod("GET")
Функция get() Экспорт

	ТипОбъектов = Неопределено;
	Счетчик = Неопределено;

	Если ТипЗнч(ЗначенияМаршрута) = Тип("Соответствие") Тогда
		ТипОбъектов = ЗначенияМаршрута.Получить("type");
		Счетчик = ЗначенияМаршрута.Получить("counter");
	КонецЕсли;
	
	ПараметрыЗапроса = ЗапросHTTP.ПараметрыЗапроса();

	Формат = "json";
	Если НЕ ПараметрыЗапроса["format"] = Неопределено Тогда
		Формат = ПараметрыЗапроса["format"];
	КонецЕсли;

	Фильтр = ОбщегоНазначения.ФильтрИзПараметровЗапроса(ПараметрыЗапроса);

	Первые = ОбщегоНазначения.ВыборкаПервыхИзПараметровЗапроса(ПараметрыЗапроса);

	Измерения = "";
	Если НЕ ПараметрыЗапроса["dim"] = Неопределено Тогда
		Измерения = ПараметрыЗапроса["dim"];
	КонецЕсли;

	АгрегатнаяФункция = "count";
	Если НЕ ПараметрыЗапроса["agregate"] = Неопределено Тогда
		АгрегатнаяФункция = ПараметрыЗапроса["agregate"];
	КонецЕсли;

	ПараметрыСчетчиков = ПолучениеСчетчиков.ПараметрыСчетчиков();
	ПараметрыСчетчика = ПараметрыСчетчиков[ТипОбъектов];

	Поля = "";

	Для Каждого ТекИзмерение Из ПараметрыСчетчика["dimentions"] Цикл
		Если ТекИзмерение.Значение["name_rac"] = Неопределено Тогда
			ИмяПоля = ТекИзмерение.Ключ;
		Иначе
			ИмяПоля = ТекИзмерение.Значение["name_rac"];
			Если ВРег(Прав(ИмяПоля, 6)) = "-LABEL" Тогда
				ИмяПоля = Сред(ИмяПоля, 1, СтрДлина(ИмяПоля) - 6);
			КонецЕсли;
		КонецЕсли;
		Поля = Поля + ?(ЗначениеЗаполнено(Поля), ", ", "") + ИмяПоля;
	КонецЦикла;

	Для Каждого ТекСчетчик Из ПараметрыСчетчика["counters"] Цикл
		Если ТекСчетчик.Значение["name_rac"] = Неопределено Тогда
			ИмяПоля = ТекСчетчик.Ключ;
		Иначе
			ИмяПоля = ТекСчетчик.Значение["name_rac"];
		КонецЕсли;
		Поля = Поля + ?(ЗначениеЗаполнено(Поля), ", ", "") + ИмяПоля;
	КонецЦикла;

	Поля = ?(ЗначениеЗаполнено(Поля), Поля, "_all");

	Если ТипОбъектов = "server" Тогда
		Данные = ДанныеСерверов.Серверы(Поля, Фильтр, Истина);
	ИначеЕсли ТипОбъектов = "process" Тогда
		Данные = ДанныеПроцессов.Процессы(Поля, Фильтр, , Истина);
	ИначеЕсли ТипОбъектов = "infobase" Тогда
		Данные = ДанныеИБ.ИнформационныеБазы(Поля, Фильтр, Истина);
	ИначеЕсли ТипОбъектов = "session" Тогда
		Данные = ДанныеСеансов.Сеансы(Поля, Фильтр, , Истина);
	ИначеЕсли ТипОбъектов = "connection" Тогда
		Данные = ДанныеСоединений.Соединения(Поля, Фильтр, , Истина);
	Иначе
		Возврат Содержимое(СтрШаблон("Не обнаружены данные для типа объектов ""%1""!", ТипОбъектов));
	КонецЕсли;
	
	Результат = ПолучениеСчетчиков.Счетчики(Данные,
	                                        ТипОбъектов,
	                                        Счетчик,
	                                        Фильтр,
	                                        Первые,
	                                        Измерения,
	                                        АгрегатнаяФункция,
	                                        Формат);

	Возврат Содержимое(Результат);

КонецФункции // get()
