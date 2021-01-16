﻿#Использовать irac

Перем ПодключениеКАгентам;
Перем Соединения;

#Область ПрограммныйИнтерфейс

// Процедура инициализирует подключение к агентам управления кластерами
//
// Параметры:
//   НастройкиПодключения     - Строка,     - путь к файлу настроек управления кластерами
//                              Структура     или структура настроек управления кластерами
//
Процедура Инициализировать(Знач НастройкиПодключения = Неопределено) Экспорт

	ПодключениеКАгентам = Новый ПодключениеКАгентам(НастройкиПодключения);

КонецПроцедуры // Инициализировать()

// Функция - возвращает объект-подключение к агентам кластера 1С
//
// Возвращаемое значение:
//   ПодключениеКАгентам     - объект-подключение к агентам кластера 1С
//
Функция ПодключениеКАгентам() Экспорт
	
	Возврат ПодключениеКАгентам;

КонецФункции // ПодключениеКАгентам()

Процедура ОбновитьСоединения(Знач Поля = "_all", Знач Фильтр = Неопределено) Экспорт

	Поля = ОбщегоНазначения.СписокПолей(Поля);

	ДобавленныеСоединения = Новый Соответствие();

	Соединения = Новый Массив();

	Для Каждого ТекАгент Из ПодключениеКАгентам.Агенты() Цикл

		СоединенияАгента = СоединенияАгента(ТекАгент.Значение, Поля);

		Для Каждого ТекСоединение Из СоединенияАгента Цикл
			Если ДобавленныеСоединения[ТекСоединение["connection"]] = Неопределено Тогда
				ДобавленныеСоединения.Вставить(ТекСоединение["connection"], Истина);
			Иначе
				Продолжить;
			КонецЕсли;

			Если НЕ ОбщегоНазначения.ОбъектСоответствуетФильтру(ТекСоединение, Фильтр) Тогда
				Продолжить;
			КонецЕсли;

			Соединения.Добавить(ТекСоединение);
		КонецЦикла;

	КонецЦикла;

КонецПроцедуры // ОбновитьСоединения()

Функция Соединения(Знач Поля = "_all", Знач Фильтр = Неопределено, Знач Первые = Неопределено, Знач Обновить = Ложь) Экспорт

	Если Обновить Тогда
		ОбновитьСоединения(Поля, Фильтр);
	КонецЕсли;

	Если ТипЗнч(Первые) = Тип("Структура") И Первые.Количество > 0 Тогда
		Возврат ОбщегоНазначения.ПервыеПоЗначениюПоля(Соединения, Первые.ИмяПоля, Первые.Количество);
	КонецЕсли;

	Возврат Соединения;

КонецФункции // Соединения()

Функция Соединение(ИБ, Соединение, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить Тогда
		ОбновитьСоединения(Поля);
	КонецЕсли;

	Для Каждого ТекСоединение Из Соединения Цикл
		Если ТекСоединение["infobase-label"] = ИБ И ТекСоединение["conn-id"] = Соединение Тогда
			Возврат ТекСоединение;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Соединение()

#КонецОбласти // ПрограммныйИнтерфейс

#Область ПолучениеДанныхСоединений

Функция СоединенияАгента(Знач Агент, Знач Поля)

	СоединенияАгента = Новый Массив();

	ДобавленныеКластеры = Новый Соответствие();

	Кластеры = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из Кластеры Цикл

		Если ДобавленныеКластеры[ТекКластер.Ид()] = Неопределено Тогда
			ДобавленныеКластеры.Вставить(ТекКластер.Ид(), Истина);
		Иначе
			Продолжить;
		КонецЕсли;

		СоединенияКластера = СоединенияКластера(ТекКластер, Поля);

		Для Каждого ТекСоединение Из СоединенияКластера Цикл
			
			Если НЕ (Поля.Найти("AGENT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСоединение.Вставить("agent", СтрШаблон("%1:%2",
				                                          Агент.АдресСервераАдминистрирования(),
				                                          Агент.ПортСервераАдминистрирования()));
			КонецЕсли;
			Если НЕ (Поля.Найти("CLUSTER") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСоединение.Вставить("cluster"      , ТекКластер.Ид());
				ТекСоединение.Вставить("cluster-host" , ТекКластер.ПортСервера());
				ТекСоединение.Вставить("cluster-label",
				                       СтрШаблон("%1:%2", ТекКластер.АдресСервера(), ТекКластер.ПортСервера()));
			КонецЕсли;
			Если НЕ (Поля.Найти("COUNT") = Неопределено И Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСоединение.Вставить("count", 1);
			КонецЕсли;

			СоединенияАгента.Добавить(ТекСоединение);

		КонецЦикла;

	КонецЦикла;

	Возврат СоединенияАгента;

КонецФункции // СоединенияАгента()

Функция СоединенияКластера(Знач Кластер, Знач Поля)

	МеткиИБ = Новый Соответствие();
	
	ИБ = Кластер.ИнформационныеБазы().Список();
	Для Каждого ТекИБ Из ИБ Цикл
		МеткиИБ.Вставить(ТекИБ.Ид(), ТекИб.Имя());
	КонецЦикла;

	МеткиПроцессов = Новый Соответствие();
	
	Процессы = Кластер.РабочиеПроцессы().Список();
	Для Каждого ТекПроцесс Из Процессы Цикл
		ПоляПроцесса = Новый Структура("Метка, Сервер, Порт");
		ПоляПроцесса.Вставить("Сервер", ТекПроцесс.Получить("host"));
		ПоляПроцесса.Вставить("Порт"  , ТекПроцесс.Получить("port"));
		ПоляПроцесса.Вставить("Метка" , СтрШаблон("%1:%2", ПоляПроцесса.Сервер, ПоляПроцесса.Порт));

		МеткиПроцессов.Вставить(ТекПроцесс.Ид(), ПоляПроцесса);
	КонецЦикла;

	СоединенияКластера = Новый Массив();

	СписокСоединений = Кластер.Получить("Соединения").Список(, , Истина);

	ПоляСоединения = Кластер.Соединения().ПараметрыОбъекта().ОписаниеСвойств("ИмяРАК");

	Для Каждого ТекСоединение Из СписокСоединений Цикл
		
		ОписаниеСоединения = Новый Соответствие();

		Для Каждого ТекЭлемент Из ПоляСоединения Цикл

			Если Поля.Найти(ВРег(ТекЭлемент.Ключ)) = Неопределено И Поля.Найти("_ALL") = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			ЗначениеЭлемента = ТекСоединение[ТекЭлемент.Значение.Имя];
			Если ТекЭлемент.Ключ = "infobase" Тогда
				ОписаниеСоединения.Вставить("infobase-label", МеткиИБ[ЗначениеЭлемента]);
			ИначеЕсли ТекЭлемент.Ключ = "process" Тогда
				ОписаниеСоединения.Вставить("process-label", МеткиПроцессов[ЗначениеЭлемента].Метка);
				ОписаниеСоединения.Вставить("process-host" , МеткиПроцессов[ЗначениеЭлемента].Сервер);
			ИначеЕсли ТекЭлемент.Ключ = "connected-at" Тогда
				ОписаниеСоединения.Вставить("duration", ТекущаяДата() - ЗначениеЭлемента);
			ИначеЕсли ТекЭлемент.Ключ = "application" И Лев(ЗначениеЭлемента, 1) = """"  И Прав(ЗначениеЭлемента, 1) = """" Тогда
				ЗначениеЭлемента = Сред(ЗначениеЭлемента, 2, СтрДлина(ЗначениеЭлемента) - 2);
			КонецЕсли;
			ОписаниеСоединения.Вставить(ТекЭлемент.Ключ, ЗначениеЭлемента);

		КонецЦикла;

		СоединенияКластера.Добавить(ОписаниеСоединения);

	КонецЦикла;

	Возврат СоединенияКластера;
	
КонецФункции // СоединенияКластера()

#КонецОбласти // ПолучениеДанныхСоединений

Инициализировать();
