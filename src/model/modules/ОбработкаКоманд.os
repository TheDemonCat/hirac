﻿#Использовать irac

Перем АгентыУправленияКластерами;
Перем ПараметрыУправленияКластерами;
Перем ПараметрыСчетчиков;

Функция АгентыУправленияКластерами() Экспорт
	
	Если АгентыУправленияКластерами = Неопределено Тогда
		ИнициализироватьАгентыУправленияКластерами();
	КонецЕсли;

	Возврат АгентыУправленияКластерами;

КонецФункции // АгентыУправленияКластерами()

Функция ПараметрыУправленияКластерами() Экспорт
	
	Если ПараметрыУправленияКластерами = Неопределено Тогда
		ПараметрыУправленияКластерами = ПрочитатьНастройкиИзJSON("racsettings");
	КонецЕсли;

	Возврат ПараметрыУправленияКластерами;

КонецФункции // ПараметрыУправленияКластерами()

Функция ПараметрыСчетчиков() Экспорт
	
	Если ПараметрыСчетчиков = Неопределено Тогда
		ПараметрыСчетчиков = ПрочитатьНастройкиИзJSON("counters");
	КонецЕсли;

	Возврат ПараметрыСчетчиков;

КонецФункции // ПараметрыСчетчиков()

Функция СтруктураПараметровАгентов()
	
	ПараметрыКластера = Новый Соответствие();
	ПараметрыКластера.Вставить("cluster"   , "");
	ПараметрыКластера.Вставить("admin_name", "");
	ПараметрыКластера.Вставить("admin_pwd" , "");

	ПараметрыКластеров = Новый Соответствие();
	ПараметрыКластеров.Вставить("default", ПараметрыКластера);

	ПараметрыАгента = Новый Соответствие();
	ПараметрыАгента.Вставить("name"      , "Локальный");
	ПараметрыАгента.Вставить("ras"       , "localhost:1545");
	ПараметрыАгента.Вставить("raс"       , "8.3");
	ПараметрыАгента.Вставить("admin_name", "");
	ПараметрыАгента.Вставить("admin_pwd" , "");
	ПараметрыАгента.Вставить("cluster"   , ПараметрыКластеров);

	ПараметрыАгентов = Новый Соответствие();
	ПараметрыАгентов.Вставить("default", ПараметрыАгента);

	Возврат ПараметрыАгентов;

КонецФункции // СтруктураПараметровАгентов()

Процедура ИнициализироватьАгентыУправленияКластерами() Экспорт
	
	ПараметрыАгентов = ПараметрыУправленияКластерами();
	Если ПараметрыАгентов = Неопределено Тогда
		ПараметрыАгентов = СтруктураПараметровАгентов();
	КонецЕсли;

	АгентыУправленияКластерами = Новый Соответствие();

	Для Каждого ТекПараметры Из ПараметрыАгентов Цикл
		УправлениеКластером = Новый УправлениеКластером1С(ТекПараметры.Значение["rac"],
		                                                  ТекПараметры.Значение["ras"]);
		АгентыУправленияКластерами.Вставить(ТекПараметры.Ключ, УправлениеКластером);
	КонецЦикла;

КонецПроцедуры // ИнициализироватьУправлениеКластером()

Функция ВсеСеансы() Экспорт

	ИменаИБ = Новый Соответствие();
	
	ДанныеСеансов = Новый Массив();

	Для Каждого ТекАгент Из АгентыУправленияКластерами() Цикл

		СеансыАгента = СеансыАгента(ТекАгент.Значение);

		Для Каждого ТекСеанс Из СеансыАгента Цикл
			ДанныеСеансов.Добавить(ТекСеанс);
		КонецЦикла;

	КонецЦикла;

	Возврат ДанныеСеансов;

КонецФункции // ОписаниеСеансов

Функция СеансыАгента(Знач Агент) Экспорт

	ДанныеСеансов = Новый Массив();

	Кластеры = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из Кластеры Цикл

		СеансыКластера = СеансыКластера(ТекКластер);

		Для Каждого ТекСеанс Из СеансыКластера Цикл
			
			ТекСеанс.Вставить("agent"  , Агент.Описаниеподключения());

			ДанныеСеансов.Добавить(ТекСеанс);

		КонецЦикла;

	КонецЦикла;

	Возврат ДанныеСеансов;

КонецФункции // СеансыАгента()

Функция СеансыКластера(Знач Кластер) Экспорт

	ИменаИБ = Новый Соответствие();
	
	ИБ = Кластер.ИнформационныеБазы().Список();
	Для Каждого ТекИБ Из ИБ Цикл
		ИменаИБ.Вставить(ТекИБ.Ид(), ТекИб.Имя());
	КонецЦикла;

	ДанныеСеансов = Новый Массив();

	Сеансы = Кластер.Сеансы().Список(, , Истина);

	ПоляСеанса = Кластер.Сеансы().ПараметрыОбъекта("ИмяРАК");

	Для Каждого ТекСеанс Из Сеансы Цикл
				
		ОписаниеСеанса = Новый Соответствие();
		ОписаниеСеанса.Вставить("cluster", Кластер.Имя());
		ОписаниеСеанса.Вставить("count"  , 1);

		Для Каждого ТекЭлемент Из ПоляСеанса Цикл
			ЗначениеЭлемента = ТекСеанс[ТекЭлемент.Значение.Имя];
			Если ТекЭлемент.Ключ = "infobase" Тогда
				ЗначениеЭлемента = ИменаИБ[ЗначениеЭлемента];
			КонецЕсли;
			ОписаниеСеанса.Вставить(ТекЭлемент.Ключ, ЗначениеЭлемента);
		КонецЦикла;

		ДанныеСеансов.Добавить(ОписаниеСеанса);

	КонецЦикла;

	Возврат ДанныеСеансов;
	
КонецФункции // СеансыКластера()

Функция ОписаниеСеансов() Экспорт

	ДанныеСеансов = ВсеСеансы();

	ПараметрыПолученияДанных = ПараметрыСчетчиков()["session"];

	Счетчики = ПараметрыПолученияДанных["counters"];

	Текст = Новый ТекстовыйДокумент();

	Для Каждого ТекСчетчик Из Счетчики Цикл
		
		Если НЕ ТекСчетчик.Значение["use"] Тогда
			Продолжить;
		КонецЕсли;
		
		ИмяСчетчика = ТекСчетчик.Ключ;
		ИмяИсточникаСчетчика = ИмяСчетчика;
		Если ТекСчетчик.Значение.Свойство("name_rac") Тогда
			ИмяИсточникаСчетчика = ТекСчетчик.Значение["name_rac"];
		КонецЕсли;

		ОписаниеСчетчика = ТекСчетчик.Значение["description"];
		ИзмеренияСчетчика = ТекСчетчик.Значение["dimentions"];

		Текст.ДобавитьСтроку(СтрШаблон("# HELP c1_session_%1 %2", ИмяСчетчика, ОписаниеСчетчика));
		Текст.ДобавитьСтроку(СтрШаблон("# TYPE c1_session_%1 gauge", ИмяСчетчика));

		Для Каждого ТекСеанс Из ДанныеСеансов Цикл
		
			ЗначенияИзмерений = ЗначенияИзмеренийСчетчика(ПараметрыПолученияДанных, ТекСеанс, ТекСчетчик.Значение);

			ЗначениеПоказателя = ТекСеанс[ИмяИсточникаСчетчика];

			Если НЕ ЗначениеЗаполнено(ЗначениеПоказателя) Тогда
				ЗначениеПоказателя = 0;
			КонецЕсли;
			Если ТипЗнч(ЗначениеПоказателя) = Тип("Число") Тогда
				ЗначениеПоказателя = Формат(ЗначениеПоказателя, "ЧРД=.; ЧН=; ЧГ=0");
			КонецЕсли;
			Текст.ДобавитьСтроку(СтрШаблон("c1_session_%1{%2} %3",
			                               ИмяСчетчика,
			                               ЗначенияИзмерений,
			                               ЗначениеПоказателя));
		КонецЦикла;
		Текст.ДобавитьСтроку("");
	КонецЦикла;
	
	Возврат Текст.ПолучитьТекст();

КонецФункции // ОписаниеСеансов

Функция ЗначенияИзмеренийСчетчика(Знач ПараметрыСчетчиков, Знач Сеанс, Знач Счетчик) Экспорт

	ПрефиксСчетчика = ПараметрыСчетчиков["counter_prefix"];

	ВсеИзмерения = ПараметрыСчетчиков["dimentions"];

	ИзмеренияСчетчика = Счетчик["dimentions"];

	ЗначенияИзмерений = "";
	Сообщить("!!! " + типЗнч(Сеанс) + " " + Сеанс.Количество());
	Для Каждого ТекЭлемент Из Сеанс Цикл
		Сообщить("!!! " + ТекЭлемент.Ключ + " : " + ТекЭлемент.Значение);
	КонецЦикла;
	Для Каждого ТекИзмерение Из ИзмеренияСчетчика Цикл

		ОписаниеИзмерения = ВсеИзмерения[ТекИзмерение];

		ИмяИсточникаИзмерения = ТекИзмерение;
		Если ОписаниеИзмерения.Свойство("name_rac") Тогда
			ИмяИсточникаИзмерения = ОписаниеИзмерения["name_rac"];
		КонецЕсли;

		ЗначениеИзмерения = Сеанс[ИмяИсточникаИзмерения];

		ЗначенияИзмерений = ЗначенияИзмерений +
							?(ЗначенияИзмерений = "", "", ",") +
							СтрШаблон("%1=""%2""", ТекИзмерение, ЗначениеИзмерения);
	КонецЦикла;
	
	Возврат ЗначенияИзмерений;

КонецФункции // ЗначенияИзмеренийСчетчика()

Функция ВызватьУтилитуАдминистрирования(ПараметрыЗапроса) Экспорт

	Версия = "8.3";
	Если НЕ ПараметрыЗапроса["version"] = Неопределено Тогда
		Версия = ПараметрыЗапроса["version"];
	КонецЕсли;

	Параметры = "--version";
	Если НЕ ПараметрыЗапроса["cmd"] = Неопределено Тогда
		Параметры = ПараметрыЗапроса["cmd"];
	КонецЕсли;

	ИсполнительКоманд = Новый ИсполнительКоманд(Версия);

	ВыводКоманды = ИсполнительКоманд.ВыполнитьКоманду(Параметры);

	Если НЕ ПараметрыЗапроса["pretty"] = Неопределено Тогда
		ВыводКоманды = РазобратьВыводКоманды(ВыводКоманды);
	КонецЕсли;


	Результат = Новый Структура();
	
	Результат.Вставить("Параметры"   , Параметры);
	Результат.Вставить("Версия"      , ИсполнительКоманд.ВерсияУтилитыАдминистрирования());
	Результат.Вставить("КодВозврата" , ИсполнительКоманд.КодВозврата());
	Результат.Вставить("ВыводКоманды", ВыводКоманды);

	Запись = Новый ЗаписьJSON();
	
	Запись.УстановитьСтроку(Новый ПараметрыЗаписиJSON(ПереносСтрокJSON.Unix, Символы.Таб));

	Попытка
		ЗаписатьJSON(Запись, Результат);
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;
	
	Возврат Запись.Закрыть();

КонецФункции // ВызватьУтилитуАдминистрирования()

// Функция преобразует переданный текст вывода команды в массив соответствий
// элементы массива создаются по блокам текста, разделенным пустой строкой
// пары <ключ, значение> структуры получаются для каждой строки с учетом разделителя ":"
//   
// Параметры:
//   ВыводКоманды            - Строка            - текст для разбора
//   
// Возвращаемое значение:
//    Массив (Соответствие) - результат разбора
//
Функция РазобратьВыводКоманды(Знач ВыводКоманды)
	
	Текст = Новый ТекстовыйДокумент();
	Текст.УстановитьТекст(ВыводКоманды);

	МассивРезультатов = Новый Массив();
	Описание = Новый Соответствие();

	Для й = 1 По Текст.КоличествоСтрок() Цикл

		ТекстСтроки = Текст.ПолучитьСтроку(й);
		
		ПозРазделителя = СтрНайти(ТекстСтроки, ":");
		
		Если НЕ ЗначениеЗаполнено(ТекстСтроки) Тогда
			Если й = 1 Тогда
				Продолжить;
			КонецЕсли;
			МассивРезультатов.Добавить(Описание);
			Описание = Новый Соответствие();
			Продолжить;
		КонецЕсли;

		Если ПозРазделителя = 0 Тогда
			Описание.Вставить(СокрЛП(ТекстСтроки), "");
		Иначе
			Описание.Вставить(СокрЛП(Лев(ТекстСтроки, ПозРазделителя - 1)), СокрЛП(Сред(ТекстСтроки, ПозРазделителя + 1)));
		КонецЕсли;
		
	КонецЦикла;

	Если Описание.Количество() > 0 Тогда
		МассивРезультатов.Добавить(Описание);
	КонецЕсли;
	
	Если МассивРезультатов.Количество() = 1 И ТипЗнч(МассивРезультатов[0]) = Тип("Строка") Тогда
		Возврат МассивРезультатов[0];
	КонецЕсли;

	Возврат МассивРезультатов;

КонецФункции // РазобратьВыводКоманды()

// Функция - читает указанный файл настроек JSON и возвращает содержимое в виде структуры/массива
//
// Параметры:
//	ИмяФайлаНастроек    - Строка   - имя файла настроек json (без расширения)
//
// Возвращаемое значение:
//	Структура, Массив       - прочитанные настройки 
//
Функция ПрочитатьНастройкиИзJSON(Знач ИмяФайлаНастроек) Экспорт

	Чтение = Новый ЧтениеJSON();
	
	ПутьКНастройкам = СтрШаблон("%1/%2.json", ТекущийКаталог(), ИмяФайлаНастроек);

	Чтение.ОткрытьФайл(ПутьКНастройкам, КодировкаТекста.UTF8);

	Возврат ПрочитатьJSON(Чтение, Ложь);

КонецФункции // ПрочитатьНастройкиИзJSON()