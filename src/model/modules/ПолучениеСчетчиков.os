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
		ПараметрыСчетчиков = ОбщегоНазначения.ПрочитатьДанныеИзМакетаJSON("/config/counters");
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

Функция Счетчики(Знач ТипОбъектов, Знач Объекты, Знач ФорматСчетчиков) Экспорт

	ПараметрыСчетчиковОбъекта = ПараметрыСчетчиков()[ТипОбъектов];

	Если ФорматСчетчиков = "json" Тогда
		Возврат СчетчикиJSON(ПараметрыСчетчиковОбъекта, Объекты);
	ИначеЕсли ФорматСчетчиков = "prometheus" Тогда
		Возврат СчетчикиPrometheus(ПараметрыСчетчиковОбъекта, Объекты);
	Иначе
		Возврат "";
	КонецЕсли;

КонецФункции // Счетчики()

Функция СчетчикиJSON(Знач ПараметрыСчетчиковОбъекта, Знач Объекты)

	ОписаниеСчетчиков = ПараметрыСчетчиковОбъекта["counters"];

	ПрефиксСчетчиков = ПараметрыСчетчиковОбъекта["counter_prefix"];

	Счетчики = Новый Массив();

	Для Каждого ТекСчетчик Из ОписаниеСчетчиков Цикл
		
		Если НЕ ТекСчетчик.Значение["use"] Тогда
			Продолжить;
		КонецЕсли;
		
		ЗначенияСчетчика = Новый Соответствие();

		ИмяСчетчика = ТекСчетчик.Ключ;
		ИмяИсточникаСчетчика = ИмяСчетчика;
		Если ТекСчетчик.Значение.Свойство("name_rac") Тогда
			ИмяИсточникаСчетчика = ТекСчетчик.Значение["name_rac"];
		КонецЕсли;

		ЗаголовокСчетчика = СтрШаблон("%1_%2", ПрефиксСчетчиков, ИмяСчетчика);

		ОписаниеСчетчика = ТекСчетчик.Значение["description"];
		ИзмеренияСчетчика = ТекСчетчик.Значение["dimentions"];

		ЗначенияСчетчика.Вставить(ЗаголовокСчетчика, Новый Соответствие());
		ЗначенияСчетчика[ЗаголовокСчетчика].Вставить("description", ОписаниеСчетчика);
		ЗначенияСчетчика[ЗаголовокСчетчика].Вставить("values", Новый Массив());

		Для Каждого ТекОбъект Из Объекты Цикл
		
			ЗначениеСчетчика = ЗначенияИзмеренийСчетчика(ПараметрыСчетчиковОбъекта, ТекОбъект, ТекСчетчик.Значение);

			ЗначениеСчетчика.Вставить("_value", ТекОбъект[ИмяИсточникаСчетчика]);

			ЗначенияСчетчика[ЗаголовокСчетчика]["values"].Добавить(ЗначениеСчетчика);

		КонецЦикла;

		Счетчики.Добавить(ЗначенияСчетчика);

	КонецЦикла;
	
	Запись = Новый ЗаписьJSON();
	
	Запись.УстановитьСтроку(Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Unix, Символы.Таб));

	Попытка
		ЗаписатьJSON(Запись, Счетчики);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;
	
	Возврат ОбщегоНазначения.ДанныеВJSON(Счетчики);

КонецФункции // СчетчикиJSON()

Функция СчетчикиPrometheus(Знач ПараметрыСчетчиковОбъекта, Знач Объекты)

	ПрефиксСчетчиков = ПараметрыСчетчиковОбъекта["counter_prefix"];

	ОписаниеСчетчиков = ПараметрыСчетчиковОбъекта["counters"];

	Текст = Новый ТекстовыйДокумент();

	Для Каждого ТекСчетчик Из ОписаниеСчетчиков Цикл
		
		Если НЕ ТекСчетчик.Значение["use"] Тогда
			Продолжить;
		КонецЕсли;
		
		ИмяСчетчика = ТекСчетчик.Ключ;
		ИмяИсточникаСчетчика = ИмяСчетчика;
		Если ТекСчетчик.Значение.Свойство("name_rac") Тогда
			ИмяИсточникаСчетчика = ТекСчетчик.Значение["name_rac"];
		КонецЕсли;

		ЗаголовокСчетчика = СтрШаблон("_%1_%2", ПрефиксСчетчиков, ИмяСчетчика);

		ОписаниеСчетчика = ТекСчетчик.Значение["description"];
		ИзмеренияСчетчика = ТекСчетчик.Значение["dimentions"];

		Текст.ДобавитьСтроку(СтрШаблон("# HELP %1 %2", ЗаголовокСчетчика, ОписаниеСчетчика));
		Текст.ДобавитьСтроку(СтрШаблон("# TYPE %1 gauge", ЗаголовокСчетчика));

		Для Каждого ТекОбъект Из Объекты Цикл
		
			ЗначенияИзмерений = ЗначенияИзмеренийСчетчика(ПараметрыСчетчиковОбъекта, ТекОбъект, ТекСчетчик.Значение);

			ЗначенияИзмеренийСтрокой = "";

			Для Каждого ТекЭлемент Из ЗначенияИзмерений Цикл
				ЗначенияИзмеренийСтрокой = ЗначенияИзмеренийСтрокой +
				                           ?(ЗначенияИзмеренийСтрокой = "", "", ",") +
				                           СтрШаблон("%1=""%2""", ТекЭлемент.Ключ, ТекЭлемент.Значение);
			КонецЦикла;

			ЗначениеПоказателя = ТекОбъект[ИмяИсточникаСчетчика];

			Если НЕ ЗначениеЗаполнено(ЗначениеПоказателя) Тогда
				ЗначениеПоказателя = 0;
			КонецЕсли;
			Если ТипЗнч(ЗначениеПоказателя) = Тип("Число") Тогда
				ЗначениеПоказателя = Формат(ЗначениеПоказателя, "ЧРД=.; ЧН=; ЧГ=0");
			КонецЕсли;
			Текст.ДобавитьСтроку(СтрШаблон("%1{%2} %3",
			                               ЗаголовокСчетчика,
			                               ЗначенияИзмеренийСтрокой,
			                               ЗначениеПоказателя));
		КонецЦикла;
		Текст.ДобавитьСтроку("");
	КонецЦикла;
	
	Возврат Текст.ПолучитьТекст();

КонецФункции // СчетчикиPrometheus()

#КонецОбласти // ПрограммныйИнтерфейс

Функция ЗначенияИзмеренийСчетчика(Знач ПараметрыСчетчиковОбъекта, Знач Объект, Знач Счетчик)

	ВсеИзмерения = ПараметрыСчетчиковОбъекта["dimentions"];

	ИзмеренияСчетчика = Счетчик["dimentions"];

	ЗначенияИзмерений = Новый Соответствие();
	
	Для Каждого ТекИзмерение Из ИзмеренияСчетчика Цикл

		ОписаниеИзмерения = ВсеИзмерения[ТекИзмерение];

		ИмяИсточникаИзмерения = ТекИзмерение;
		Если ОписаниеИзмерения.Свойство("name_rac") Тогда
			ИмяИсточникаИзмерения = ОписаниеИзмерения["name_rac"];
		КонецЕсли;

		ЗначениеИзмерения = Объект[ИмяИсточникаИзмерения];

		ЗначенияИзмерений.Вставить(ТекИзмерение, ЗначениеИзмерения);

	КонецЦикла;
	
	Возврат ЗначенияИзмерений;

КонецФункции // ЗначенияИзмеренийСчетчика()

#КонецОбласти // ПрограммныйИнтерфейс

Инициализировать();
