﻿
Перем ПараметрыСчетчиков;

#Область ПрограммныйИнтерфейс

// Процедура инициализирует получение счетчиков
//
Процедура Инициализировать() Экспорт

	УстановитьПараметрыСчетчиков();
	
КонецПроцедуры // Инициализировать()

// Процедура устанавливает параметры счетчиков
//
// Параметры:
//   НовыеПараметры     - Строка,     - путь к файлу настроек счетчиков
//                        Структура     или структура настроек счетчиков
//
Процедура УстановитьПараметрыСчетчиков(Знач НовыеПараметры = Неопределено) Экспорт
	
	Если ТипЗнч(НовыеПараметры) = Тип("Структура") Тогда
		ПараметрыСчетчиков = НовыеПараметры;
	ИначеЕсли ТипЗнч(НовыеПараметры) = Тип("Строка") Тогда
		ПараметрыСчетчиков = ОбщегоНазначения.ПрочитатьДанныеИзМакетаJSON(НовыеПараметры);
	Иначе
		ПараметрыСчетчиков = ОбщегоНазначения.ПрочитатьДанныеИзМакетаJSON("/config/counters", Истина);
	КонецЕсли;

КонецПроцедуры // УстановитьПараметрыСчетчиков()

// Функция - возвращает структуру параметров счетчиков
//
// Возвращаемое значение:
//   Структура     - структура параметров счетчиков
//
Функция ПараметрыСчетчиков() Экспорт
	
	Возврат ПараметрыСчетчиков;

КонецФункции // ПараметрыСчетчиков()

Функция Список(Знач ТипОбъектов = Неопределено) Экспорт

	Счетчики = Новый Соответствие();

	Для Каждого ТекРаздел Из ПараметрыСчетчиков() Цикл

		Если ЗначениеЗаполнено(ТипОбъектов) И НЕ ВРег(ТекРаздел.Ключ) = ВРег(ТипОбъектов) Тогда
			Продолжить;
		КонецЕсли;

		Счетчики.Вставить(ТекРаздел.Ключ, Новый Соответствие());
		
		РазделСчетчиков = Счетчики[ТекРаздел.Ключ];
		СчетчикиРаздела = ТекРаздел.Значение["counters"];

		Если СчетчикиРаздела = Неопределено Тогда
			Продолжить;
		КонецЕсли;

		Для Каждого ТекСчетчик Из СчетчикиРаздела Цикл
			Если НЕ ТекСчетчик.Значение["use"] Тогда
				Продолжить;
			КонецЕсли;
			РазделСчетчиков.Вставить(ТекСчетчик.Ключ, ТекСчетчик.Значение);
		КонецЦикла;

	КонецЦикла;

	Возврат ОбщегоНазначения.ДанныеВJSON(Счетчики);

КонецФункции // Список()

Функция АгрегироватьЗначенияСчетчика(ЗначенияСчетчика, Знач РезультирующиеИзмерения = "", Знач АгрегатнаяФункция = "count")

	Если ТипЗнч(РезультирующиеИзмерения) = Тип("Строка") Тогда
		Измерения = СтрРазделить(РезультирующиеИзмерения, ",", Ложь);
		Для й = 0 По Измерения.ВГраница() Цикл
			Измерения[й] = СокрЛП(Измерения[й]);
		КонецЦикла;
	ИначеЕсли ТипЗнч(РезультирующиеИзмерения) = Тип("Массив") Тогда
		Измерения = РезультирующиеИзмерения;
	Иначе
		Измерения = Новый Массив();
	КонецЕсли;

	Если НЕ Измерения.Найти("_all") = Неопределено Тогда
		Возврат ЗначенияСчетчика;
	ИначеЕсли НЕ Измерения.Найти("_no") = Неопределено Тогда
		Измерения = Новый Массив();
	КонецЕсли;

	АгрегатныеФункции = ВРЕг("sum,min,max,avg,count,distinct");
	Если Найти(АгрегатныеФункции, ВРег(АгрегатнаяФункция)) = 0 Тогда
		АгрегатнаяФункция = "count";
	КонецЕсли;
	
	ГруппыЗначений = Новый Соответствие();

	Для Каждого ТекЗначение Из ЗначенияСчетчика Цикл
		ИзмеренияСтрокой = "";
		Для Каждого ТекИзмерение Из Измерения Цикл
			Если ТекЗначение[ТекИзмерение] = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			ИзмеренияСтрокой = СтрШаблон("%1%2=%3;", ИзмеренияСтрокой, ТекИзмерение, ТекЗначение[ТекИзмерение]);
		КонецЦикла;
		Если ГруппыЗначений[ИзмеренияСтрокой] = Неопределено Тогда
			ГруппыЗначений.Вставить(ИзмеренияСтрокой, Новый Массив());
		КонецЕсли;
		ГруппыЗначений[ИзмеренияСтрокой].Добавить(ТекЗначение);
	КонецЦикла;

	АгрегированныеЗначения = Новый Массив();

	Для Каждого ТекЭлемент Из ГруппыЗначений Цикл
		Сумма = Неопределено;
		Мин = Неопределено;
		Макс = Неопределено;
		Количество = 0;
		Различные = Новый Соответствие();

		АгрегированноеЗначение = Новый Соответствие();
		Для Каждого ТекИзмерение Из Измерения Цикл
			АгрегированноеЗначение.Вставить(ТекИзмерение, ТекЭлемент.Значение[0][ТекИзмерение]);
		КонецЦикла;
		Для Каждого ТекЗначение Из ТекЭлемент.Значение Цикл
			Если ТипЗнч(ТекЗначение["_value"]) = Тип("Число") Тогда
				Сумма = ?(Сумма = Неопределено, ТекЗначение["_value"], Сумма + ТекЗначение["_value"]);
			КонецЕсли;
			Мин = ?(Мин = Неопределено, ТекЗначение["_value"], Мин(Мин, ТекЗначение["_value"]));
			Макс = ?(Макс = Неопределено, ТекЗначение["_value"], Макс(Макс, ТекЗначение["_value"]));
			Количество = Количество + 1;
			Различные.Вставить(ТекЗначение["_value"], 1);
		КонецЦикла;
		Если ВРег(АгрегатнаяФункция) = ВРег("sum") Тогда
			АгрегированноеЗначение.Вставить("_value", Сумма);
		ИначеЕсли ВРег(АгрегатнаяФункция) = ВРег("min") Тогда
			АгрегированноеЗначение.Вставить("_value", Мин);
		ИначеЕсли ВРег(АгрегатнаяФункция) = ВРег("max") Тогда
			АгрегированноеЗначение.Вставить("_value", Макс);
		ИначеЕсли ВРег(АгрегатнаяФункция) = ВРег("avg") Тогда
			Если ТипЗнч(Сумма) = Тип("Число") Тогда
				АгрегированноеЗначение.Вставить("_value", Сумма / Количество);
			Иначе
				АгрегированноеЗначение.Вставить("_value", Неопределено);
			КонецЕсли;
		ИначеЕсли ВРег(АгрегатнаяФункция) = ВРег("distinct") Тогда
			АгрегированноеЗначение.Вставить("_value", Различные.Количество());
		Иначе
			АгрегированноеЗначение.Вставить("_value", Количество);
		КонецЕсли;

		АгрегированныеЗначения.Добавить(АгрегированноеЗначение);
	КонецЦикла;

	Возврат АгрегированныеЗначения;

КонецФункции // АгрегироватьЗначенияСчетчика()

Функция Счетчики(Знач Объекты,
	             Знач ТипОбъектов,
	             Знач Счетчик = "",
	             Знач Фильтр = Неопределено,
	             Знач Первые = Неопределено,
	             Знач Измерения = "",
	             Знач АгрегатнаяФункция = "count",
	             Знач ФорматСчетчиков = "json") Экспорт

	ПараметрыСчетчиковОбъекта = ПараметрыСчетчиков()[ТипОбъектов];

	Счетчики = ЗначенияСчетчиков(Объекты, ПараметрыСчетчиковОбъекта, Счетчик, Фильтр);

	Если ЗначениеЗаполнено(Измерения) Тогда
		Для Каждого ТекЭлемент Из Счетчики Цикл
			ТекЭлемент.Значение["values"] = АгрегироватьЗначенияСчетчика(ТекЭлемент.Значение["values"],
			                                                             Измерения,
			                                                             АгрегатнаяФункция);
		КонецЦикла;
	КонецЕсли;

	Для Каждого ТекЭлемент Из Счетчики Цикл
		Если НЕ ЗначениеЗаполнено(ТекЭлемент.Значение["values"]) Тогда
			ТекЭлемент.Значение["values"] = Новый Массив();
			ТекЭлемент.Значение["values"].Добавить(Новый Соответствие());
			ТекЭлемент.Значение["values"][0].Вставить("_value", Неопределено);
		КонецЕсли;
	КонецЦикла;
	
	Если ТипЗнч(Первые) = Тип("Структура") И Первые.Количество > 0 Тогда
		Для Каждого ТекЭлемент Из Счетчики Цикл
			ТекЭлемент.Значение["values"] = ОбщегоНазначения.ПервыеПоЗначениюПоля(ТекЭлемент.Значение["values"], Первые.ИмяПоля, Первые.Количество);
		КонецЦикла;
	КонецЕсли;

	ПрефиксСчетчиков = ПараметрыСчетчиковОбъекта["counter_prefix"];

	Если ФорматСчетчиков = "json" Тогда
		Возврат ФорматJSON(Счетчики, ПрефиксСчетчиков);
	ИначеЕсли ФорматСчетчиков = "prometheus" Тогда
		Возврат ФорматPrometheus(Счетчики, ПрефиксСчетчиков);
	ИначеЕсли ФорматСчетчиков = "plain" Тогда
		Возврат ФорматPlain(Счетчики, ПрефиксСчетчиков);
	Иначе
		Возврат "";
	КонецЕсли;

КонецФункции // Счетчики()

Функция ЗначенияСчетчиков(Знач Объекты, Знач ПараметрыСчетчиковОбъекта, Знач Счетчик = "", Знач Фильтр = Неопределено)

	ОписаниеСчетчиков = ПараметрыСчетчиковОбъекта["counters"];

	Счетчики = Новый Соответствие();

	Для Каждого ТекСчетчик Из ОписаниеСчетчиков Цикл
		
		Если НЕ ТекСчетчик.Значение["use"] Тогда
			Продолжить;
		КонецЕсли;

		Если НЕ ВРег(ТекСчетчик.Ключ) = ВРег(Счетчик) И ЗначениеЗаполнено(Счетчик) Тогда
			Продолжить;
		КонецЕсли;
	
		ИмяСчетчика = ТекСчетчик.Ключ;
		ИмяИсточникаСчетчика = ИмяСчетчика;
		Если НЕ ТекСчетчик.Значение["name_rac"] = Неопределено Тогда
			ИмяИсточникаСчетчика = ТекСчетчик.Значение["name_rac"];
		КонецЕсли;

		ОписаниеСчетчика = ТекСчетчик.Значение["description"];

		Счетчики.Вставить(ИмяСчетчика, Новый Соответствие());
		Счетчики[ИмяСчетчика].Вставить("description", ОписаниеСчетчика);
		Счетчики[ИмяСчетчика].Вставить("values", Новый Массив());

		Для Каждого ТекОбъект Из Объекты Цикл
		
			Если НЕ ОбщегоНазначения.ОбъектСоответствуетФильтру(ТекОбъект, Фильтр) Тогда
				Продолжить;
			КонецЕсли;

			ЗначениеСчетчика = ЗначенияИзмеренийСчетчика(ПараметрыСчетчиковОбъекта, ТекОбъект, ТекСчетчик.Значение);

			ЗначениеСчетчика.Вставить("_value", ТекОбъект[ИмяИсточникаСчетчика]);

			Счетчики[ИмяСчетчика]["values"].Добавить(ЗначениеСчетчика);

		КонецЦикла;

		Счетчики[ИмяСчетчика]["values"] = АгрегироватьЗначенияСчетчика(Счетчики[ИмяСчетчика]["values"],
		                                                               ТекСчетчик.Значение["dimentions"],
		                                                               ТекСчетчик.Значение["agregate"]);
	КонецЦикла;
	
	Возврат Счетчики;

КонецФункции // ЗначенияСчетчиков()

Функция ФорматJSON(Счетчики, Префикс = "")

	Результат = Новый Соответствие();

	Для Каждого ТекСчетчик Из Счетчики Цикл

		ЗаголовокСчетчика = СтрШаблон("%1%2", Префикс, ТекСчетчик.Ключ);

		Результат.Вставить(ЗаголовокСчетчика, ТекСчетчик.Значение);

	КонецЦикла;

	Возврат ОбщегоНазначения.ДанныеВJSON(Результат);

КонецФункции // ФорматJSON()

Функция ФорматPrometheus(Счетчики, Префикс = "")

	Текст = Новый ТекстовыйДокумент();

	Для Каждого ТекСчетчик Из Счетчики Цикл

		ЗаголовокСчетчика = СтрШаблон("%1%2", Префикс, СтрЗаменить(ТекСчетчик.Ключ, "-", "_"));

		ОписаниеСчетчика = ТекСчетчик.Значение["description"];

		Текст.ДобавитьСтроку(СтрШаблон("# HELP %1 %2", ЗаголовокСчетчика, ОписаниеСчетчика));
		Текст.ДобавитьСтроку(СтрШаблон("# TYPE %1 gauge", ЗаголовокСчетчика));

		Для Каждого ТекЗначение Из ТекСчетчик.Значение["values"] Цикл

			ЗначенияИзмеренийСтрокой = "";
			ЗначениеСчетчика = Неопределено;
			Для Каждого ТекИзмерение Из ТекЗначение Цикл
				Если ВРег(ТекИзмерение.Ключ) = ВРег("_value") Тогда
					ЗначениеСчетчика = ТекИзмерение.Значение;
					Продолжить;
				КонецЕсли;

				ЗначениеИзмерения = ТекИзмерение.Значение;
				Если ТипЗнч(ЗначениеИзмерения) = Тип("Дата") Тогда
					ЗначениеИзмерения = Формат(ЗначениеИзмерения, "ДФ=yyyy-MM-ddThh:mm:ss");
				КонецЕсли;
				ЗначенияИзмеренийСтрокой = ЗначенияИзмеренийСтрокой +
				                           ?(ЗначенияИзмеренийСтрокой = "", "", ",") +
				                           СтрШаблон("%1=""%2""", СтрЗаменить(ТекИзмерение.Ключ, "-", "_"), ЗначениеИзмерения);
			КонецЦикла;

			Если НЕ ЗначениеЗаполнено(ЗначениеСчетчика) Тогда
				ЗначениеСчетчика = 0;
			КонецЕсли;
			Если ТипЗнч(ЗначениеСчетчика) = Тип("Число") Тогда
				ЗначениеСчетчика = Формат(ЗначениеСчетчика, "ЧРД=.; ЧН=; ЧГ=0");
			ИначеЕсли ТипЗнч(ЗначениеСчетчика) = Тип("Дата") Тогда
				ЗначениеСчетчика = Формат(ЗначениеСчетчика, "ДФ=yyyy-MM-ddThh:mm:ss");
			КонецЕсли;
			Текст.ДобавитьСтроку(СтрШаблон("%1{%2} %3",
			                               ЗаголовокСчетчика,
			                               ЗначенияИзмеренийСтрокой,
			                               ЗначениеСчетчика));
		КонецЦикла;

		Текст.ДобавитьСтроку("");

	КонецЦикла;

	Возврат Текст.ПолучитьТекст();

КонецФункции // ФорматPrometheus()

Функция ФорматPlain(Счетчики, Префикс = "")

	Текст = Новый ТекстовыйДокумент();

	Для Каждого ТекСчетчик Из Счетчики Цикл

		Для Каждого ТекЗначение Из ТекСчетчик.Значение["values"] Цикл
			
			ЗначениеСчетчика = ТекЗначение["_value"];
			
			Если НЕ ЗначениеЗаполнено(ЗначениеСчетчика) Тогда
				ЗначениеСчетчика = 0;
			КонецЕсли;
			
			Если ТипЗнч(ЗначениеСчетчика) = Тип("Число") Тогда
				ЗначениеСчетчика = Формат(ЗначениеСчетчика, "ЧРД=.; ЧН=; ЧГ=0");
			КонецЕсли;

			Текст.ДобавитьСтроку(СтрШаблон("%1%2=%3", Префикс, ТекСчетчик.Ключ, ЗначениеСчетчика));

		КонецЦикла;

	КонецЦикла;

	Возврат Текст.ПолучитьТекст();

КонецФункции // ФорматPlain()

#КонецОбласти // ПрограммныйИнтерфейс

Функция ЗначенияИзмеренийСчетчика(Знач ПараметрыСчетчиковОбъекта, Знач Объект, Знач Счетчик)

	ВсеИзмерения = ПараметрыСчетчиковОбъекта["dimentions"];

	ИзмеренияСчетчика = Счетчик["dimentions"];

	ЗначенияИзмерений = Новый Соответствие();
	
	Для Каждого ТекИзмерение Из ИзмеренияСчетчика Цикл

		ОписаниеИзмерения = ВсеИзмерения[ТекИзмерение];

		ИмяИсточникаИзмерения = ТекИзмерение;
		Если НЕ ОписаниеИзмерения["name_rac"] = Неопределено Тогда
			ИмяИсточникаИзмерения = ОписаниеИзмерения["name_rac"];
		КонецЕсли;

		ЗначениеИзмерения = Объект[ИмяИсточникаИзмерения];

		ЗначенияИзмерений.Вставить(ТекИзмерение, ЗначениеИзмерения);

	КонецЦикла;
	
	Возврат ЗначенияИзмерений;

КонецФункции // ЗначенияИзмеренийСчетчика()

#КонецОбласти // ПрограммныйИнтерфейс

Инициализировать();
