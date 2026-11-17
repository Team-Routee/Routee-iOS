//
//  WorkoutTimeLineViewModel.swift
//  Routee-iOS
//
//  Created by LEESANGYUP on 11/10/26.
//

import Foundation

@MainActor
final class WorkoutTimeLineViewModel {
    private let activityRepository: ActivityRepository
    private var savedActivityTitle: String
    private var savedRoutes: [RouteData]

    init(
        title: String,
        courseRoutes: [CourseListModel.RouteData],
        activityRepository: ActivityRepository
    ) {
        self.activityRepository = activityRepository
        savedActivityTitle = title
        savedRoutes = courseRoutes.sorted { $0.sequence < $1.sequence }.map {
            RouteData(routeId: $0.routeId, name: $0.name, sequence: $0.sequence)
        }
    }

    func deleteActivity(activityId: Int64) async throws {
        try await activityRepository.deleteActivity(activityId: activityId)
    }

    func updateActivityTitle(activityId: Int64?, title: String) async throws {
        guard title != savedActivityTitle else { return }
        guard let activityId else { throw RouteeError.noData }

        _ = try await activityRepository.updateArchiveActivityTitle(
            activityId: activityId,
            requestDTO: UpdateArchiveActivityTitleRequestDTO(title: title)
        )
        savedActivityTitle = title
    }

    func updateCourseList(activityId: Int64?, titles: [String], routeIds: [Int64]) async throws -> [Int64]? {
        let namedRoutes = zip(titles, routeIds).enumerated().compactMap { index, route -> (index: Int, name: String, routeId: Int64)? in
            let (title, routeId) = route
            let name = title.trimmingCharacters(in: .whitespacesAndNewlines)
            return name.isEmpty ? nil : (index: index, name: name, routeId: routeId)
        }
        let routes = namedRoutes.enumerated().map { offset, route in
            RouteData(routeId: route.routeId, name: route.name, sequence: offset + 1)
        }
        let hasChanges = routes.count != savedRoutes.count || zip(routes, savedRoutes).contains {
            $0.routeId != $1.routeId || $0.name != $1.name || $0.sequence != $1.sequence
        }
        guard hasChanges else { return nil }
        guard let activityId else { throw RouteeError.noData }

        let response = try await activityRepository.updateCourseList(
            activityId: activityId,
            requestDTO: UpdateCourseListRequestDTO(routes: routes)
        )

        var updatedRouteIds = routeIds
        savedRoutes = zip(namedRoutes, routes).map { namedRoute, route in
            let routeId = response.routes.first { $0.sequence == route.sequence }?.routeId ?? route.routeId
            updatedRouteIds[namedRoute.index] = routeId
            return RouteData(routeId: routeId, name: route.name, sequence: route.sequence)
        }
        return updatedRouteIds
    }
}
