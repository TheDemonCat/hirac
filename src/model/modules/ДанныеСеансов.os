﻿#Использовать irac

Перем ПодключениеКАгентам;
Перем Сеансы;

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

Процедура ОбновитьСеансы(Знач Поля = "_all") Экспорт

	Если ТипЗнч(Поля) = Тип("Строка") Тогда
		Поля = СтрРазделить(Поля, ",", Ложь);
		Для й = 0 По Поля.ВГраница() Цикл
			Поля[й] = ВРег(СокрЛП(Поля[й]));
		КонецЦикла;
	ИначеЕсли НЕ ТипЗнч(Поля) = Тип("Массив") Тогда
		Поля = Новый Массив();
		Поля.Добавить("_ALL");
	КонецЕсли;

	Сеансы = Новый Массив();

	Для Каждого ТекАгент Из ПодключениеКАгентам.Агенты() Цикл

		СеансыАгента = СеансыАгента(ТекАгент.Значение, Поля);

		Для Каждого ТекСеанс Из СеансыАгента Цикл
			Сеансы.Добавить(ТекСеанс);
		КонецЦикла;

	КонецЦикла;

КонецПроцедуры // ОбновитьСеансы()

Функция Сеансы(Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить Тогда
		ОбновитьСеансы(Поля);
	КонецЕсли;

	Возврат Сеансы;

КонецФункции // Сеансы()

Функция Сеанс(ИБ, Сеанс, Знач Поля = "_all", Знач Обновить = Ложь) Экспорт

	Если Обновить Тогда
		ОбновитьСеансы(Поля);
	КонецЕсли;

	Для Каждого ТекСеанс Из Сеансы Цикл
		Если ТекСеанс["infobase"] = ИБ И ТекСеанс["session-id"] = Сеанс Тогда
			Возврат ТекСеанс;
		КонецЕсли;
	КонецЦикла;

	Возврат Неопределено;

КонецФункции // Сеанс()

#КонецОбласти // ПрограммныйИнтерфейс

#Область ПолучениеДанныхСеансов

Функция СеансыАгента(Знач Агент, Знач Поля)

	СеансыАгента = Новый Массив();

	Кластеры = Агент.Кластеры().Список();

	Для Каждого ТекКластер Из Кластеры Цикл

		СеансыКластера = СеансыКластера(ТекКластер, Поля);

		Для Каждого ТекСеанс Из СеансыКластера Цикл
			
			Если НЕ (Поля.Найти("AGENT") = Неопределено ИЛИ Поля.Найти("_ALL") = Неопределено) Тогда
				ТекСеанс.Вставить("agent", СтрШаблон("%1:%2",
				                                     Агент.АдресСервераАдминистрирования(),
				                                     Агент.ПортСервераАдминистрирования()));
			КонецЕсли;
			СеансыАгента.Добавить(ТекСеанс);

		КонецЦикла;

	КонецЦикла;

	Возврат СеансыАгента;

КонецФункции // СеансыАгента()

Функция СеансыКластера(Знач Кластер, Знач Поля)

	ИменаИБ = Новый Соответствие();
	
	ИБ = Кластер.ИнформационныеБазы().Список();
	Для Каждого ТекИБ Из ИБ Цикл
		ИменаИБ.Вставить(ТекИБ.Ид(), ТекИб.Имя());
	КонецЦикла;

	СеансыКластера = Новый Массив();

	СписокСеансов = Кластер.Сеансы().Список(, , Истина);

	ПоляСеанса = Кластер.Сеансы().ПараметрыОбъекта("ИмяРАК");

	Для Каждого ТекСеанс Из СписокСеансов Цикл
		
		ОписаниеСеанса = Новый Соответствие();
		Если НЕ (Поля.Найти("CLUSTER") = Неопределено ИЛИ Поля.Найти("_ALL") = Неопределено) Тогда
			ОписаниеСеанса.Вставить("cluster" , Кластер.Имя());
		КонецЕсли;
		Если НЕ (Поля.Найти("COUNT") = Неопределено ИЛИ Поля.Найти("_ALL") = Неопределено) Тогда
			ОписаниеСеанса.Вставить("count"   , 1);
		КонецЕсли;

		Для Каждого ТекЭлемент Из ПоляСеанса Цикл
			Если Поля.Найти(ВРег(ТекЭлемент.Ключ)) = Неопределено И Поля.Найти("_ALL") = Неопределено Тогда
				Продолжить;
			КонецЕсли;
			ЗначениеЭлемента = ТекСеанс[ТекЭлемент.Значение.Имя];
			Если ТекЭлемент.Ключ = "infobase" Тогда
				ЗначениеЭлемента = ИменаИБ[ЗначениеЭлемента];
			ИначеЕсли ТекЭлемент.Ключ = "started-at" Тогда
				ОписаниеСеанса.Вставить("duration", ТекущаяДата() - ЗначениеЭлемента);
			КонецЕсли;
			ОписаниеСеанса.Вставить(ТекЭлемент.Ключ, ЗначениеЭлемента);
		КонецЦикла;

		СеансыКластера.Добавить(ОписаниеСеанса);

	КонецЦикла;

	Возврат СеансыКластера;
	
КонецФункции // СеансыКластера()

#КонецОбласти // ПолучениеДанныхСеансов

Инициализировать();
